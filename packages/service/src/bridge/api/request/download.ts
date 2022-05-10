import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeFailure,
  invokeSuccess
} from "@nzoth/bridge"
import { isString, isNumber } from "@nzoth/shared"
import { Events, MAX_TIMEOUT, headerValueToString } from "./util"
import { env } from "../../index"

let requestId = 0
const downloadTasks: Map<number, DownloadTask> = new Map()

interface DownloadProgressResult {
  progress: number
  totalBytesWritten: number
  totalBytesExpectedToWrite: number
}

type DownloadProgressCallback = (result: DownloadProgressResult) => void

class DownloadTask {
  taskId: number

  private progressCallbacks: DownloadProgressCallback[] = []

  constructor() {
    this.taskId = requestId += 1
    downloadTasks.set(this.taskId, this)
  }

  abort() {
    InnerJSBridge.invoke("cancelRequest", { taskId: this.taskId })
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
    this.progressCallbacks.forEach(cb => {
      cb(result)
    })
  }

  /** @internal */
  destroy() {
    this.progressCallbacks = []
  }
}

InnerJSBridge.subscribe<DownloadProgressResult & { taskId: number }>(
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

type DownloadFileSuccessCallback = (
  res: DownloadFileSuccessCallbackResult
) => void

type DownloadFileFailCallback = (res: GeneralCallbackResult) => void

type DownloadFileCompleteCallback = (res: GeneralCallbackResult) => void

export function downloadFile<
  T extends DownloadFileOptions = DownloadFileOptions
>(options: T): DownloadTask | undefined {
  const event = Events.DOWNLOAD_FILE
  if (!options.url || !isString(options.url)) {
    invokeFailure(event, options, "download url cannot be empty")
    return
  }

  if (!/^https?:\/\//.test(options.url)) {
    invokeFailure(event, options, "download url scheme invalid")
    return
  }

  let filePath = ""
  if (options.filePath) {
    if (
      !isString(options.filePath) ||
      !options.filePath.startsWith(env.USER_DATA_PATH + "/")
    ) {
      invokeFailure(event, options, "download filePath invalid")
      return
    }
    filePath = options.filePath.substring(env.USER_DATA_PATH.length + 1)
  }

  let header = options.header || {}
  header = headerValueToString(header)

  let timeout = isNumber(options.timeout) ? options.timeout : MAX_TIMEOUT
  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT
  }

  let url = options.url

  const request = {
    url,
    header,
    timeout: timeout,
    filePath,
    taskId: 0
  }

  const task = new DownloadTask()
  request.taskId = task.taskId

  InnerJSBridge.invoke<SuccessResult<T>>(event, request, result => {
    task.destroy()
    downloadTasks.delete(task.taskId)
    if (result.errMsg) {
      invokeFailure(event, options, result.errMsg)
      return
    } else {
      if (filePath) {
        result.data!.filePath = options.filePath!
      }
      invokeSuccess(event, options, result.data)
    }
  })
  return task
}
