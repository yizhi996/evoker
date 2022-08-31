import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeFailure,
  invokeSuccess,
  USER_DATA_PATH,
  ERR_INVALID_ARG_TYPE,
  ERR_INVALID_ARG_VALUE,
  ERR_CANNOT_EMPTY
} from "@evoker/bridge"
import { isString } from "@vue/shared"
import { Events, MAX_TIMEOUT, headerValueToString } from "./util"
import { Task } from "./task"

const downloadTasks: Map<string, DownloadTask> = new Map()

interface DownloadProgressResult {
  /** 下载进度百分比, 0 - 100 */
  progress: number
  /** 已经下载的数据长度，单位 Bytes */
  totalBytesWritten: number
  /** 预期需要下载的数据总长度，单位 Bytes */
  totalBytesExpectedToWrite: number
}

type DownloadProgressCallback = (result: DownloadProgressResult) => void

/** 一个可以监听下载进度变化事件，以及取消下载任务的对象 */
class DownloadTask extends Task {
  private progressCallbacks: DownloadProgressCallback[] = []

  constructor() {
    super("down")
    downloadTasks.set(this.taskId, this)
  }

  /** 监听下载进度变化事件 */
  onProgressUpdate(callback: DownloadProgressCallback) {
    if (!this.progressCallbacks.includes(callback)) {
      this.progressCallbacks.push(callback)
    }
  }

  /** 取消监听下载进度变化事件 */
  offProgressUpdate(callback: DownloadProgressCallback) {
    const index = this.progressCallbacks.indexOf(callback)
    if (index > -1) {
      this.progressCallbacks.splice(index, 1)
    }
  }

  /** @internal */
  dispatchProgressCallback(result: DownloadProgressResult) {
    if (this.isCancel) {
      this.destroy()
    } else {
      this.progressCallbacks.forEach(cb => {
        cb(result)
      })
    }
  }

  /** @internal */
  destroy() {
    this.progressCallbacks = []
    downloadTasks.delete(this.taskId)
  }
}

InnerJSBridge.subscribe<DownloadProgressResult & { taskId: string }>(
  "APP_DOWNLOAD_FILE_PROGRESS",
  result => {
    const task = downloadTasks.get(result.taskId)
    task && task.dispatchProgressCallback(result)
  }
)

interface DownloadFileOptions {
  /** 下载资源的 url */
  url: string
  /** HTTP 请求的 Header */
  header?: Record<string, string>
  /** 超时时间，单位为毫秒 */
  timeout?: number
  /** 指定文件下载后存储的路径 (本地路径) */
  filePath?: string
  /** 接口调用成功的回调函数 */
  success?: DownloadFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: DownloadFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: DownloadFileCompleteCallback
}

interface DownloadFileSuccessCallbackResult {
  /** 服务器返回的数据长度 */
  dataLength: number
  /** 服务器返回的 HTTP Response Header */
  header: Record<string, string>
  /** 临时文件路径 (本地路径)。没传入 filePath 指定文件存储路径时会返回，下载后的文件会存储到一个临时文件 */
  tempFilePath: string
  /** 用户文件路径 (本地路径)。传入 filePath 时会返回，跟传入的 filePath 一致 */
  filePath: string
  /** 服务器返回的 HTTP 状态码 */
  statusCode: number
}

type DownloadFileSuccessCallback = (res: DownloadFileSuccessCallbackResult) => void

type DownloadFileFailCallback = (res: GeneralCallbackResult) => void

type DownloadFileCompleteCallback = (res: GeneralCallbackResult) => void

/** 下载文件资源到本地。客户端直接发起一个 GET 请求，返回文件的本地临时路径 (本地路径) */
export function downloadFile<T extends DownloadFileOptions = DownloadFileOptions>(
  options: T
): DownloadTask | undefined {
  const event = Events.DOWNLOAD_FILE
  let { url, filePath = "", header = {}, timeout = MAX_TIMEOUT } = options

  if (!isString(url)) {
    invokeFailure(event, options, ERR_INVALID_ARG_TYPE("options.url", "string", url))
    return
  }

  if (!url) {
    invokeFailure(event, options, ERR_INVALID_ARG_VALUE("options.url", url, ERR_CANNOT_EMPTY))
    return
  }

  if (!/^https?:\/\//.test(url)) {
    invokeFailure(
      event,
      options,
      ERR_INVALID_ARG_VALUE("options.url", url, "scheme wrong, needs http / https")
    )
    return
  }

  if (filePath) {
    if (!isString(filePath)) {
      invokeFailure(event, options, ERR_INVALID_ARG_TYPE("options.filePath", "string", filePath))
      return
    }

    const prefix = USER_DATA_PATH + "/"
    if (!filePath.startsWith(prefix)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.filePath", filePath, `requires start with ${prefix}`)
      )
      return
    }

    filePath = filePath.substring(USER_DATA_PATH.length + 1)
  }

  header = headerValueToString(header)

  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT
  }

  const task = new DownloadTask()

  const request = {
    url,
    header,
    timeout,
    filePath,
    taskId: task.taskId
  }

  InnerJSBridge.invoke<SuccessResult<T>>(event, request, result => {
    task.destroy()
    if (result.errMsg) {
      invokeFailure(event, options, result.errMsg)
      return
    } else {
      if (task.isCancel) {
        invokeFailure(event, options, "abort")
        return
      }
      if (filePath) {
        result.data!.filePath = options.filePath!
      }
      invokeSuccess(event, options, result.data)
    }
  })
  return task
}
