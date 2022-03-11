import { invoke } from "../bridge"

let requestId = 0

class RequestTask {
  /** @internal */
  id: number

  constructor() {
    this.id = requestId += 1
  }

  abort() {
    invoke("cancelRequest", { id: this.id })
  }

  toJSON() {
    return this.id
  }
}

export interface RequestOptions {
  url: string
  data?: string | Record<string, any> | ArrayBuffer
  header?: Record<string, any>
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
  dataType?: "json" | ""
  responseType?: "text" | "arraybuffer"
  task?: RequestTask
}

interface RequestResponse<
  T extends string | Record<string, any> | ArrayBuffer
> {
  data: T
  cookies: string[]
  header: Record<string, string>
  statusCode: number
}

export function request<T extends string | Record<string, any> | ArrayBuffer>(
  options: RequestOptions
): Promise<RequestResponse<T>> {
  const header = {
    accept: "*/*",
    "accept-encoding": "gzip, deflate",
    "content-type": "application/json"
  }
  Object.assign(header, options.header)

  const defaultOptions = {
    url: "",
    header: header,
    method: "GET",
    dataType: "json",
    responseType: "text",
    timeout: 60 * 1000
  }
  Object.assign(defaultOptions, options)

  if (defaultOptions.url.length === 0) {
    console.error("request url can not empty")
    return Promise.reject()
  }

  return new Promise((resolve, reject) => {
    invoke("request", defaultOptions, result => {
      if (result.errMsg && result.errMsg.length) {
        reject(result.errMsg)
      } else {
        const response = result.data as RequestResponse<T>
        if (defaultOptions.dataType === "json") {
          try {
            response.data = JSON.parse(response.data as string)
          } catch {}
        }
        resolve(response)
      }
    })
  })
}

interface DownloadFileOptions {
  url: string
  header?: Record<string, string>
  timeout?: number
}

interface DownloadFileResponse {
  tempFilePath: string
  filePath: string
  statusCode: number
  header: Record<string, string>
}

export function downloadFile(
  options: DownloadFileOptions
): Promise<DownloadFileResponse> {
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
    return Promise.reject("request url can not empty")
  }

  return new Promise((resolve, reject) => {
    invoke("downloadFile", defaultOptions, result => {
      if (result.errMsg && result.errMsg.length) {
        reject(result.errMsg)
      } else {
        const response = result.data as DownloadFileResponse
        resolve(response)
      }
    })
  })
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
    invoke("uploadFile", defaultOptions, result => {
      if (result.errMsg && result.errMsg.length) {
        reject(result.errMsg)
      } else {
        const response = result.data as UploadFileResponse
        resolve(response)
      }
    })
  })
}
