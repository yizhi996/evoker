import { InnerJSBridge } from "../../bridge"
import { SuccessResult, GeneralCallbackResult, invokeFailure, invokeSuccess } from "@evoker/bridge"
import { isString } from "@vue/shared"
import { Events, MAX_TIMEOUT, headerValueToString } from "./util"
import { Task } from "./task"
import { EKFILE_SCHEME } from "../const"

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

  onProgressUpdate(callback: UploadProgressCallback) {
    if (!this.progressCallbacks.includes(callback)) {
      this.progressCallbacks.push(callback)
    }
  }

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
  url: string
  filePath: string
  name: string
  header?: Record<string, string>
  formData?: Record<string, any>
  timeout?: number
  success?: UploadFileSuccessCallback
  fail?: UploadFileFailCallback
  complete?: UploadFileCompleteCallback
}

interface UploadFileSuccessCallbackResult {
  dataLength: number
  header: Record<string, string>
  tempFilePath: string
  filePath: string
  statusCode: number
}

type UploadFileSuccessCallback = (res: UploadFileSuccessCallbackResult) => void

type UploadFileFailCallback = (res: GeneralCallbackResult) => void

type UploadFileCompleteCallback = (res: GeneralCallbackResult) => void

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
