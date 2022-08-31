import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeFailure,
  invokeSuccess,
  fetchArrayBuffer,
  ERR_INVALID_ARG_TYPE,
  ERR_INVALID_ARG_VALUE,
  ERR_CANNOT_EMPTY
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
  /** 服务器接口地址 */
  url: string
  /** 请求的参数 */
  data?: string | Object | ArrayBuffer
  /** 设置请求的 header，content-type 默认为 application/json */
  header?: Record<string, string>
  /** 超时时间，单位为毫秒 */
  timeout?: number
  /** HTTP 请求方法
   *
   * 可选值：
   * - OPTIONS:	HTTP 请求 OPTIONS
   * - GET:	HTTP 请求 GET
   * - HEAD: HTTP 请求 HEAD
   * - POST: HTTP 请求 POST
   * - PUT: HTTP 请求 PUT
   * - DELETE: HTTP 请求 DELETE
   * - TRACE: HTTP 请求 TRACE
   * - CONNECT: HTTP 请求 CONNECT
   */
  method?: RequestMethod
  /** 返回的数据格式
   *
   * 可选值：
   * - json: 返回的数据为 JSON，返回后会对返回的数据进行一次 JSON.parse
   * - 其他: 不对返回的内容进行 JSON.parse
   */
  dataType?: "json" | string
  /** 响应的数据类型
   *
   * 可选值：
   * - text: 响应的数据为文本
   * - arraybuffer: 响应的数据为 ArrayBuffer
   */
  responseType?: "text" | "arraybuffer"
  /** 接口调用成功的回调函数 */
  success?: RequestSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: RequestFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: RequestCompleteCallback
}

interface RequestSuccessCallbackResult {
  /** 服务器返回的数据 */
  data: string | Record<any, any> | ArrayBuffer
  /** 服务器返回的 HTTP 状态码 */
  statusCode: number
  /** 服务器返回的 HTTP Response Header */
  header: Record<string, string>
  /** 服务器返回的 cookies，格式为字符串数组 */
  cookies: string[]
}

type RequestSuccessCallback = (res: RequestSuccessCallbackResult) => void

type RequestFailCallback = (res: GeneralCallbackResult) => void

type RequestCompleteCallback = (res: GeneralCallbackResult) => void

/** 发起 HTTP 网络请求 */
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
    } else if (task.isCancel) {
      invokeFailure(event, options, "abort")
    } else {
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
