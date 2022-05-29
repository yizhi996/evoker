import { InnerJSBridge } from "../../bridge"
import { SuccessResult, GeneralCallbackResult, invokeFailure, invokeSuccess } from "@nzoth/bridge"
import { isString, isObject, isArrayBuffer, extend } from "@nzoth/shared"
import { Task } from "./task"
import {
  Events,
  CONTENT_TYPE,
  MAX_TIMEOUT,
  headerValueToString,
  headerContentTypeKeyToLowerCase,
  queryStringToObject,
  objectToQueryString
} from "./util"

class RequestTask extends Task {
  constructor() {
    super("req")
  }
}

type RequestMethod = "OPTIONS" | "GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "TRACE" | "CONNECT"

interface RequestOptions {
  url: string
  data?: string | Record<any, any> | ArrayBuffer
  header?: Record<string, string>
  timeout?: number
  method?: RequestMethod
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
  const event = Events.REQUEST
  let {
    url,
    header = {},
    data = "",
    method = "GET",
    responseType = "text",
    timeout = MAX_TIMEOUT
  } = options

  if (!url || !isString(url)) {
    invokeFailure(event, options, "request url cannot be empty")
    return
  }

  if (!/^https?:\/\//.test(url)) {
    invokeFailure(event, options, "request url scheme wrong, need http / https")
    return
  }

  header = headerValueToString(header)
  header = headerContentTypeKeyToLowerCase(header)
  header[CONTENT_TYPE] = header[CONTENT_TYPE] || "application/json"

  const contentType = header[CONTENT_TYPE]

  method = method.toUpperCase() as RequestMethod
  if (method === "GET") {
    if (isObject(data) && Object.keys(data).length > 0) {
      const [ogURL, ogQuery] = url.split("?")
      let query = data
      if (ogQuery) {
        query = queryStringToObject(ogQuery)
        query = extend(query, data)
      }
      url = ogURL + "?" + objectToQueryString(query)
      data = ""
    }
  } else if (method === "HEAD") {
    data = ""
  } else if (!isString(data) && !isArrayBuffer(data)) {
    if (contentType.includes("application/x-www-form-urlencoded")) {
      data = objectToQueryString(data)
    } else if (contentType.includes("application/json")) {
      data = JSON.stringify(data)
    }
  }

  if (!["text", "arraybuffer"].includes(responseType)) {
    responseType = "text"
  }

  if (timeout > MAX_TIMEOUT) {
    timeout = MAX_TIMEOUT
  }

  const task = new RequestTask()

  const request = {
    url,
    header,
    method,
    data,
    dataType: options.dataType || "json",
    responseType,
    timeout,
    taskId: task.taskId
  }

  InnerJSBridge.invoke<SuccessResult<T>>(event, request, result => {
    if (result.errMsg) {
      invokeFailure(event, options, result.errMsg)
      return
    } else {
      if (task.isCancel) {
        invokeFailure(event, options, "abort")
        return
      }
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
      invokeSuccess(event, options, result.data)
    }
  })
  return task
}
