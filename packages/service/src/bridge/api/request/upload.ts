import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeFailure,
  invokeSuccess,
  EKFILE_SCHEME
} from "@evoker/bridge"
import { isString } from "@vue/shared"
import { Events, MAX_TIMEOUT, headerValueToString } from "./util"
import { Task } from "./task"

const uploadTasks: Map<string, UploadTask> = new Map()

interface UploadProgressResult {
  progress: number
  totalBytesWritten: number
  totalBytesExpectedToWrite: number
}

type UploadProgressCallback = (result: UploadProgressResult) => void

class UploadTask extends Task {
  private progressCallbacks: UploadProgressCallback[] = []

  constructor() {
    super("up")
    uploadTasks.set(this.taskId, this)
  }

  /** 监听上传进度变化事件 */
  onProgressUpdate(callback: UploadProgressCallback) {
    if (!this.progressCallbacks.includes(callback)) {
      this.progressCallbacks.push(callback)
    }
  }

  /** 取消监听上传进度变化事件 */
  offProgressUpdate(callback: UploadProgressCallback) {
    const index = this.progressCallbacks.indexOf(callback)
    if (index > -1) {
      this.progressCallbacks.splice(index, 1)
    }
  }

  /** @internal */
  dispatchProgressCallback(result: UploadProgressResult) {
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
    uploadTasks.delete(this.taskId)
  }
}

InnerJSBridge.subscribe<UploadProgressResult & { taskId: string }>(
  "APP_UPLOAD_FILE_PROGRESS",
  result => {
    const task = uploadTasks.get(result.taskId)
    task && task.dispatchProgressCallback(result)
  }
)

interface UploadFileOptions {
  /** 服务器地址 */
  url: string
  /** 要上传文件资源的路径 (本地路径) */
  filePath: string
  /** 文件对应的 key，开发者在服务端可以通过这个 key 获取文件的二进制内容 */
  name: string
  /** HTTP 请求的 Header */
  header?: Record<string, string>
  /** HTTP 请求中其他额外的 form data */
  formData?: Record<string, any>
  /** 超时时间，单位为毫秒 */
  timeout?: number
  /** 接口调用成功的回调函数 */
  success?: UploadFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: UploadFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: UploadFileCompleteCallback
}

interface UploadFileSuccessCallbackResult {
  /** 服务器返回的数据 */
  data: string
  /** 服务器返回的 HTTP Response Header */
  header: Record<string, string>
  /** 服务器返回的 HTTP 状态码 */
  statusCode: number
}

type UploadFileSuccessCallback = (res: UploadFileSuccessCallbackResult) => void

type UploadFileFailCallback = (res: GeneralCallbackResult) => void

type UploadFileCompleteCallback = (res: GeneralCallbackResult) => void

/** 将本地资源上传到服务器。客户端发起一个 HTTPS POST 请求，其中 content-type 为 multipart/form-data */
export function uploadFile<T extends UploadFileOptions = UploadFileOptions>(
  options: T
): UploadTask | undefined {
  const event = Events.UPLOAD_FILE
  let { url, name, filePath, header = {}, formData = {}, timeout = MAX_TIMEOUT } = options
  if (!url || !isString(url)) {
    invokeFailure(event, options, "upload url cannot be empty")
    return
  }

  if (!/^https?:\/\//.test(url)) {
    invokeFailure(event, options, "upload url scheme invalid")
    return
  }

  if (!name || !isString(name)) {
    invokeFailure(event, options, "upload name invalid")
    return
  }

  if (!filePath || !isString(filePath) || !filePath.startsWith(EKFILE_SCHEME)) {
    invokeFailure(event, options, "upload filePath invalid")
    return
  }

  header = headerValueToString(header)

  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT
  }

  formData = headerValueToString(formData)

  const task = new UploadTask()

  const request = {
    url,
    header,
    name,
    timeout,
    filePath,
    formData,
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
      invokeSuccess(event, options, result.data)
    }
  })
  return task
}
