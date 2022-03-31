import { isNumber, isObject, isString, isBoolean } from "@nzoth/shared"
import { invoke } from "../bridge"
import {
  invokeCallback,
  invokeSuccess,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../async"

const enum Events {
  GET = "getStorage",
  SET = "setStorage",
  REMOVE = "removeStorage",
  CLEAR = "clearStorage",
  INFO = "getStorageInfo"
}

const enum DataType {
  STRING = "String",
  NUMBER = "Number",
  BOOLEAN = "Boolean",
  BIGINT = "BitInt",
  ARRAY = "Array",
  OBJECT = "Object",
  DATE = "Date",
  UNDEFINED = "Undefined",
  NULL = "Null"
}

interface GetStorageOptions<T> {
  key: string
  success?: GetStorageSuccessCallback<T>
  fail?: GetStorageFailCallback
  complete?: GetStorageCompleteCallback
}

interface GetStorageSuccessCallbackResult<T> {
  data: T
}

type GetStorageSuccessCallback<T> = (
  res: GetStorageSuccessCallbackResult<T>
) => void

type GetStorageFailCallback = (res: GeneralCallbackResult) => void

type GetStorageCompleteCallback = (res: GeneralCallbackResult) => void

export function getStorage<
  T = any,
  U extends GetStorageOptions<T> = GetStorageOptions<T>
>(options: U): AsyncReturn<U, GetStorageOptions<T>> {
  return wrapperAsyncAPI<U>(options => {
    if (!isString(options.key)) {
      invokeFailure(Events.GET, options, "key type required string")
      return
    }
    invoke<SuccessResult<U>>(Events.GET, { key: options.key }, result => {
      if (result.errMsg && result.errMsg.length) {
        invokeFailure(Events.GET, options, result.errMsg)
      } else {
        const { data, dataType } = result.data as any
        let finalData: unknown
        switch (dataType) {
          case DataType.STRING:
            finalData = data
            break
          case DataType.NUMBER:
            finalData = Number(data)
            break
          case DataType.BOOLEAN:
            finalData = data === "true"
            break
          case DataType.BIGINT:
            finalData = BigInt(data as string)
            break
          case DataType.ARRAY:
            finalData = JSON.parse(data)
            break
          case DataType.OBJECT:
            finalData = JSON.parse(data)
            break
          case DataType.DATE:
            finalData = new Date(parseInt(data))
            break
          case DataType.UNDEFINED:
            finalData = undefined
            break
          case DataType.NULL:
            finalData = null
            break
          default:
            invokeFailure(
              Events.GET,
              options,
              "data type illegal, supports string, number, boolean, bigint, array, object, date, undefined or null."
            )
            return
        }
        invokeSuccess(Events.GET, options, { data: finalData })
      }
    })
  }, options)
}

interface SetStorageOptions<T> {
  key: string
  data: T
  success?: SetStorageSuccessCallback
  fail?: SetStorageFailCallback
  complete?: SetStorageCompleteCallback
}

type SetStorageSuccessCallback = (res: GeneralCallbackResult) => void

type SetStorageFailCallback = (res: GeneralCallbackResult) => void

type SetStorageCompleteCallback = (res: GeneralCallbackResult) => void

export function setStorage<
  T = any,
  U extends SetStorageOptions<T> = SetStorageOptions<T>
>(options: U): AsyncReturn<U, SetStorageOptions<T>> {
  return wrapperAsyncAPI<U>(options => {
    if (!isString(options.key)) {
      invokeFailure(Events.SET, options, "key type required string")
      return
    }

    let data = options.data as unknown
    let type = ""
    if (isString(data)) {
      type = "String"
    } else if (isNumber(data)) {
      data = data.toString()
      type = DataType.NUMBER
    } else if (isBoolean(data)) {
      data = data ? "true" : "false"
      type = DataType.OBJECT
    } else if (isObject(data)) {
      data = JSON.stringify(data)
      type = DataType.OBJECT
    } else if (Array.isArray(data)) {
      data = JSON.stringify(data)
      type = DataType.ARRAY
    } else if (data instanceof Date) {
      data = data + ""
      type = DataType.DATE
    } else if (data === undefined) {
      data = "undefined"
      type = DataType.UNDEFINED
    } else if (data === null) {
      data = "null"
      type = DataType.NULL
    } else if (typeof data === "bigint") {
      data = data.toString()
      type = DataType.BIGINT
    } else {
      invokeFailure(
        Events.SET,
        options,
        "data type illegal, supports string, number, boolean, bigint, array, object, date, undefined or null."
      )
      return
    }

    invoke<SuccessResult<U>>(
      Events.SET,
      { key: options.key, data, dataType: type },
      result => {
        invokeCallback(Events.SET, options, result)
      }
    )
  }, options)
}

interface RemoveStorageOptions {
  key: string
  success?: RemoveStorageSuccessCallback
  fail?: RemoveStorageFailCallback
  complete?: RemoveStorageCompleteCallback
}

type RemoveStorageSuccessCallback = (res: GeneralCallbackResult) => void

type RemoveStorageFailCallback = (res: GeneralCallbackResult) => void

type RemoveStorageCompleteCallback = (res: GeneralCallbackResult) => void

export function removeStorage<
  T extends RemoveStorageOptions = RemoveStorageOptions
>(options: T): AsyncReturn<T, RemoveStorageOptions> {
  return wrapperAsyncAPI<T>(options => {
    if (!isString(options.key)) {
      invokeFailure(Events.REMOVE, options, "key type required string")
      return
    }

    invoke<SuccessResult<T>>(Events.REMOVE, { key: options.key }, result => {
      invokeCallback(Events.REMOVE, options, result)
    })
  }, options)
}

interface ClearStorageOptions {
  success?: ClearStorageSuccessCallback
  fail?: ClearStorageFailCallback
  complete?: ClearStorageCompleteCallback
}

type ClearStorageSuccessCallback = (res: GeneralCallbackResult) => void

type ClearStorageFailCallback = (res: GeneralCallbackResult) => void

type ClearStorageCompleteCallback = (res: GeneralCallbackResult) => void

export function clearStorage<
  T extends ClearStorageOptions = ClearStorageOptions
>(options: T): AsyncReturn<T, ClearStorageOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.CLEAR, {}, result => {
      invokeCallback(Events.CLEAR, options, result)
    })
  }, options)
}

interface GetStorageInfoOptions {
  success?: GetStorageInfoSuccessCallback
  fail?: GetStorageInfoFailCallback
  complete?: GetStorageInfoCompleteCallback
}

interface GetStorageInfoSuccessCallbackResult {
  keys: string[]
  currentSize: number
  limitSize: number
  errMsg: string
}

type GetStorageInfoSuccessCallback = (
  res: GetStorageInfoSuccessCallbackResult
) => void

type GetStorageInfoFailCallback = (res: GeneralCallbackResult) => void

type GetStorageInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getStorageInfo<
  T extends GetStorageInfoOptions = GetStorageInfoOptions
>(options: T): AsyncReturn<T, GetStorageInfoOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.INFO, {}, result => {
      invokeCallback(Events.INFO, options, result)
    })
  }, options)
}
