import { InnerJSBridge } from "../../bridge"
import { SuccessResult, GeneralCallbackResult, invokeFailure, invokeSuccess } from "@evoker/bridge"
import { isString } from "@vue/shared"
import { Events, MAX_TIMEOUT, headerValueToString } from "./util"
import { env } from "../const"
import { Task } from "./task"

const downloadTasks: Map<string, DownloadTask> = new Map()

interface DownloadProgressResult {
  progress: number
  totalBytesWritten: number
  totalBytesExpectedToWrite: number
}

type DownloadProgressCallback = (result: DownloadProgressResult) => void

class DownloadTask extends Task {
  private progressCallbacks: DownloadProgressCallback[] = []

  constructor() {
    super("down")
    downloadTasks.set(this.taskId, this)
  }

  onProgressUpdate(callback: DownloadProgressCallback) {
    if (!this.progressCallbacks.includes(callback)) {
      this.progressCallbacks.push(callback)
    }
  }

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
  url: string
  header?: Record<string, string>
  timeout?: number
  filePath?: string
  success?: DownloadFileSuccessCallback
  fail?: DownloadFileFailCallback
  complete?: DownloadFileCompleteCallback
}

interface DownloadFileSuccessCallbackResult {
  dataLength: number
  header: Record<string, string>
  tempFilePath: string
  filePath: string
  statusCode: number
}

type DownloadFileSuccessCallback = (res: DownloadFileSuccessCallbackResult) => void

type DownloadFileFailCallback = (res: GeneralCallbackResult) => void

type DownloadFileCompleteCallback = (res: GeneralCallbackResult) => void

export function downloadFile<T extends DownloadFileOptions = DownloadFileOptions>(
  options: T
): DownloadTask | undefined {
  const event = Events.DOWNLOAD_FILE
  let { url, filePath = "", header = {}, timeout = MAX_TIMEOUT } = options
  if (!url || !isString(url)) {
    invokeFailure(event, options, "download url cannot be empty")
    return
  }

  if (!/^https?:\/\//.test(url)) {
    invokeFailure(event, options, "download url scheme invalid")
    return
  }

  if (filePath) {
    if (!isString(filePath) || !filePath.startsWith(env.USER_DATA_PATH + "/")) {
      invokeFailure(event, options, "download filePath invalid")
      return
    }
    filePath = filePath.substring(env.USER_DATA_PATH.length + 1)
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
