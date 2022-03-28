import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeFailure,
  invokeSuccess
} from "@nzoth/bridge"
import { isString, isNumber, isObject, isArrayBuffer } from "@nzoth/shared"
import {
  Events,
  CONTENT_TYPE,
  MAX_TIMEOUT,
  headerValueToString,
  headerContentTypeKeyToLowerCase,
  queryStringToObject,
  objectToQueryString
} from "./util"

let requestId = 0

class RequestTask {
  taskId: number

  constructor() {
    this.taskId = requestId += 1
  }

  abort() {
    InnerJSBridge.invoke("cancelRequest", { taskId: this.taskId })
  }

  toJSON() {
    return this.taskId
  }
}

interface RequestOptions {
  url: string
  data?: string | Record<any, any> | ArrayBuffer
  header?: Record<string, string>
  timeout?: number
  method?:
    | "OPTIONS"
    | "GET"
    | "HEAD"
    | "POST"
    | "PUT"
    | "DELETE"
    | "TRACE"
    | "CONNECT"
  dataType?: "json" | string
  responseType?: "text" | "arraybuffer"
  success?: RequestSuccessCallback
  fail?: RequestFailCallback
  complete?: RequestCompleteCallback
}

interface RequestSuccessCallbackResult {
  data: string | Record<any, any> | ArrayBuffer
  statusCode: number
  header: Record<string, string>
  cookies: string[]
}

type RequestSuccessCallback = (res: RequestSuccessCallbackResult) => void

type RequestFailCallback = (res: GeneralCallbackResult) => void

type RequestCompleteCallback = (res: GeneralCallbackResult) => void

export function request<T extends RequestOptions = RequestOptions>(
  options: T
): RequestTask | undefined {
  if (!options.url || !isString(options.url)) {
    invokeFailure(Events.REQUEST, options, "request url cannot be empty")
    return
  }

  if (!/^https?:\/\//.test(options.url)) {
    invokeFailure(Events.REQUEST, options, "request url scheme wrong")
    return
  }

  let header = options.header || {}
  header = headerValueToString(header)
  header = headerContentTypeKeyToLowerCase(header)
  header[CONTENT_TYPE] = header[CONTENT_TYPE] || "application/json"

  const contentType = header[CONTENT_TYPE]

  let url = options.url
  let data = options.data || ""

  let method: string = options.method || "GET"
  method = method.toUpperCase()
  if (method === "GET") {
    if (isObject(data) && Object.keys(data).length > 0) {
      const [ogURL, ogQuery] = url.split("?")
      let query = data
      if (ogQuery) {
        query = queryStringToObject(ogQuery)
        query = Object.assign(query, data)
      }
      url = ogURL + "?" + objectToQueryString(query)
      data = ""
    }
  } else if (!isString(data) && !isArrayBuffer(data)) {
    if (contentType.includes("application/x-www-form-urlencoded")) {
      data = objectToQueryString(data)
    } else if (contentType.includes("application/json")) {
      data = JSON.stringify(data)
    }
  }

  let responseType = options.responseType || "text"
  if (!["text", "arraybuffer"].includes(responseType)) {
    responseType = "text"
  }

  let timeout = isNumber(options.timeout) ? options.timeout : MAX_TIMEOUT
  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT
  }

  const request = {
    url,
    header,
    method,
    data,
    dataType: options.dataType || "json",
    responseType,
    timeout: timeout,
    taskId: 0
  }

  const task = new RequestTask()
  request.taskId = task.taskId

  InnerJSBridge.invoke<SuccessResult<T>>(Events.REQUEST, request, result => {
    if (result.errMsg) {
      invokeFailure(Events.REQUEST, options, result.errMsg)
      return
    } else {
      let { data } = result.data as { data: string | number[] | ArrayBuffer }
      if (request.responseType === "arraybuffer") {
        data = Uint8Array.from(data as number[]).buffer
      } else {
        if (request.dataType === "json") {
          try {
            data = JSON.parse(data as string)
          } catch {}
        }
      }
      result.data!.data = data
      invokeSuccess(Events.REQUEST, options, result.data)
    }
  })
  return task
}

interface UploadFileOptions {
  url: string
  filePath: string
  name: string
  header?: Record<string, string>
  formData?: Record<string, string>
  timeout?: number
}

interface UploadFileResponse {
  data: string
  statusCode: number
}

export function uploadFile(
  options: UploadFileOptions
): Promise<UploadFileResponse> {
  const header = {
    accept: "*/*",
    "accept-encoding": "gzip, deflate"
  }
  Object.assign(header, options.header)

  const defaultOptions = {
    url: "",
    header: header,
    timeout: 60 * 1000
  }
  Object.assign(defaultOptions, options)

  if (defaultOptions.url.length === 0) {
    console.error("request url can not empty")
    return Promise.reject()
  }

  return new Promise((resolve, reject) => {
    InnerJSBridge.invoke("uploadFile", defaultOptions, result => {
      if (result.errMsg && result.errMsg.length) {
        reject(result.errMsg)
      } else {
        const response = result.data as UploadFileResponse
        resolve(response)
      }
    })
  })
}
