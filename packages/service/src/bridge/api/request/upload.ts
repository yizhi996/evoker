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
const uploadTasks: Map<number, UploadTask> = new Map()

interface UploadProgressResult {
  progress: number
  totalBytesWritten: number
  totalBytesExpectedToWrite: number
}

type UploadProgressCallback = (result: UploadProgressResult) => void

class UploadTask {
  taskId: number

  private progressCallbacks: UploadProgressCallback[] = []

  constructor() {
    this.taskId = requestId += 1
    uploadTasks.set(this.taskId, this)
  }

  abort() {
    InnerJSBridge.invoke("cancelRequest", { taskId: this.taskId })
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
    this.progressCallbacks.forEach(cb => {
      cb(result)
    })
  }

  /** @internal */
  destroy() {
    this.progressCallbacks = []
  }
}

InnerJSBridge.subscribe<UploadProgressResult & { taskId: number }>(
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
  if (!options.url || !isString(options.url)) {
    invokeFailure(Events.UPLOAD_FILE, options, "upload url cannot be empty")
    return
  }

  if (!/^https?:\/\//.test(options.url)) {
    invokeFailure(Events.UPLOAD_FILE, options, "upload url scheme invalid")
    return
  }

  if (!options.name || !isString(options.name)) {
    invokeFailure(Events.UPLOAD_FILE, options, "upload name invalid")
    return
  }

  if (
    !options.filePath ||
    !isString(options.filePath) ||
    !options.filePath.startsWith("nzfile://")
  ) {
    invokeFailure(Events.UPLOAD_FILE, options, "upload filePath invalid")
    return
  }

  let header = options.header || {}
  header = headerValueToString(header)

  let timeout = isNumber(options.timeout) ? options.timeout : MAX_TIMEOUT
  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT
  }

  let url = options.url

  let formData = options.formData || {}
  formData = headerValueToString(formData)

  const request = {
    url,
    header,
    name: options.name,
    timeout: timeout,
    filePath: options.filePath,
    formData,
    taskId: 0
  }

  const task = new UploadTask()
  request.taskId = task.taskId

  InnerJSBridge.invoke<SuccessResult<T>>(
    Events.UPLOAD_FILE,
    request,
    result => {
      task.destroy()
      uploadTasks.delete(task.taskId)
      if (result.errMsg) {
        invokeFailure(Events.UPLOAD_FILE, options, result.errMsg)
        return
      } else {
        invokeSuccess(Events.UPLOAD_FILE, options, result.data)
      }
    }
  )
  return task
}
