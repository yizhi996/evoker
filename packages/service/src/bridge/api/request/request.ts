import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeFailure,
  invokeSuccess,
  fetchArrayBuffer
} from "@evoker/bridge"
import { isArrayBuffer } from "@evoker/shared"
import { isString, extend, isPlainObject } from "@vue/shared"
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

  let __arrayBuffer__ = 0

  method = method.toUpperCase() as RequestMethod
  if (method === "GET") {
    if (isPlainObject(data) && Object.keys(data).length > 0) {
      const [ogURL, ogQuery] = url.split("?")
      let query = data
      if (ogQuery) {
        query = queryStringToObject(ogQuery)
        query = extend(query, data)
      }
      url = ogURL + "?" + objectToQueryString(query)
    }
    data = ""
  } else if (method === "HEAD") {
    data = ""
  } else if (!isString(data) && !isArrayBuffer(data)) {
    if (contentType.includes("application/x-www-form-urlencoded")) {
      data = objectToQueryString(data)
    } else if (contentType.includes("application/json")) {
      data = JSON.stringify(data)
    }
  } else if (isArrayBuffer(data)) {
    __arrayBuffer__ = globalThis.__ArrayBufferRegister.set(data)
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
    dataType: options.dataType || "json",
    responseType,
    timeout,
    taskId: task.taskId
  }

  if (__arrayBuffer__) {
    request["__arrayBuffer__"] = __arrayBuffer__
  } else {
    request["data"] = data
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

      if (request.responseType === "arraybuffer") {
        fetchArrayBuffer(result.data, "data")
      } else {
        const response = result.data as any
        const { dataString } = response as { dataString: string }
        delete response.dataString

        if (request.dataType === "json") {
          try {
            response.data = JSON.parse(dataString)
          } catch {
            response.data = dataString
          }
        } else {
          response.data = dataString
        }
      }
      invokeSuccess(event, options, result.data)
    }
  })
  return task
}
