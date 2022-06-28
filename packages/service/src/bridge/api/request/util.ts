import { isNumber } from "@evoker/shared"
import { isString } from "@vue/shared"

export const CONTENT_TYPE = "content-type"

export const MAX_TIMEOUT = 60 * 1000

export const enum Events {
  REQUEST = "request",
  DOWNLOAD_FILE = "downloadFile",
  UPLOAD_FILE = "uploadFile"
}

export function objectToQueryString(obj: Record<string, any>) {
  const str: string[] = []
  for (let k in obj)
    if (obj.hasOwnProperty(k)) {
      const v = obj[k]
      str.push(`${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    }
  return str.join("&")
}

export function queryStringToObject(str: string) {
  return str.split("&").reduce((prev, obj) => {
    if (isString(obj) && obj.length > 0) {
      const [k, v] = obj.split("=")
      prev[k] = v
    }
    return prev
  }, {} as Record<string, string>)
}

export function headerValueToString(header: Record<string, any>) {
  return Object.keys(header).reduce((prev, key) => {
    const value = header[key]
    if (isString(value)) {
      prev[key] = value
    } else if (isNumber(value)) {
      prev[key] = value + ""
    } else {
      prev[key] = value.toString()
    }
    return prev
  }, {} as Record<string, string>)
}

export function headerContentTypeKeyToLowerCase(header: Record<string, string>) {
  return Object.keys(header).reduce((prev, key) => {
    if (key.toLowerCase() === CONTENT_TYPE) {
      prev[CONTENT_TYPE] = header[key]
    } else {
      prev[key] = header[key]
    }
    return prev
  }, {} as Record<string, string>)
}
