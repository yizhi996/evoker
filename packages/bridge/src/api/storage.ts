import { isNumber, isBoolean } from "@nzoth/shared"
import { isString, isObject } from "@vue/shared"
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
import { ErrorCodes, errorMessage } from "../errors"

const enum Events {
  GET = "getStorage",
  GET_SYNC = "getStorageSync",
  SET = "setStorage",
  SET_SYNC = "setStorageSync",
  REMOVE = "removeStorage",
  REMOVE_SYNC = "removeStorageSync",
  CLEAR = "clearStorage",
  CLEAR_SYNC = "clearStorageSync",
  INFO = "getStorageInfo",
  INFO_SYNC = "getStorageInfoSync"
}

export const enum DataType {
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

function getReallyDataByDataType(data: string, dataType: DataType) {
  let reallyData: unknown
  switch (dataType) {
    case DataType.STRING:
      reallyData = data
      break
    case DataType.NUMBER:
      reallyData = Number(data)
      break
    case DataType.BOOLEAN:
      reallyData = data === "true"
      break
    case DataType.BIGINT:
      reallyData = BigInt(data as string)
      break
    case DataType.ARRAY:
      reallyData = JSON.parse(data)
      break
    case DataType.OBJECT:
      reallyData = JSON.parse(data)
      break
    case DataType.DATE:
      reallyData = new Date(parseInt(data))
      break
    case DataType.UNDEFINED:
      reallyData = undefined
      break
    case DataType.NULL:
      reallyData = null
      break
    default:
      throw new Error(
        "data type illegal, supports string, number, boolean, bigint, array, object, date, undefined or null."
      )
  }
  return reallyData
}

function dataToDataType(data: unknown) {
  let dataString = data
  let type = DataType.STRING
  if (isString(data)) {
    type = DataType.STRING
  } else if (isNumber(data)) {
    dataString = data.toString()
    type = DataType.NUMBER
  } else if (isBoolean(data)) {
    dataString = data ? "true" : "false"
    type = DataType.OBJECT
  } else if (isObject(data)) {
    dataString = JSON.stringify(data)
    type = DataType.OBJECT
  } else if (Array.isArray(data)) {
    dataString = JSON.stringify(data)
    type = DataType.ARRAY
  } else if (data instanceof Date) {
    dataString = data + ""
    type = DataType.DATE
  } else if (data === undefined) {
    dataString = "undefined"
    type = DataType.UNDEFINED
  } else if (data === null) {
    dataString = "null"
    type = DataType.NULL
  } else if (typeof data === "bigint") {
    dataString = data.toString()
    type = DataType.BIGINT
  } else {
    throw new Error(
      "data type illegal, supports string, number, boolean, bigint, array, object, date, undefined or null."
    )
  }
  return { data: dataString as string, dataType: type }
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

type GetStorageSuccessCallback<T> = (res: GetStorageSuccessCallbackResult<T>) => void

type GetStorageFailCallback = (res: GeneralCallbackResult) => void

type GetStorageCompleteCallback = (res: GeneralCallbackResult) => void

export function getStorage<T = any, U extends GetStorageOptions<T> = GetStorageOptions<T>>(
  options: U
): AsyncReturn<U, GetStorageOptions<T>> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET
    if (!isString(options.key)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "key"))
      return
    }
    invoke<{ data: string; dataType: DataType }>(event, { key: options.key }, result => {
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
      } else {
        const { data: dataString, dataType } = result.data!
        try {
          const data = getReallyDataByDataType(dataString, dataType)
          invokeSuccess(event, options, { data })
        } catch (error) {
          invokeFailure(event, options, (error as Error).message)
        }
      }
    })
  }, options)
}

export function getStorageSync(key: string): any {
  const event = Events.GET_SYNC
  if (!isString(key)) {
    return
  }
  const { errMsg, result } = globalThis.__NZAppServiceNativeSDK.storage.getStorageSync(key)
  if (errMsg) {
    return ""
  } else {
    const { data, dataType } = result
    try {
      return getReallyDataByDataType(data, dataType)
    } catch (error) {
      throw new Error(`${event}:fail ${(error as Error).message}`)
    }
  }
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

export function setStorage<T = any, U extends SetStorageOptions<T> = SetStorageOptions<T>>(
  options: U
): AsyncReturn<U, SetStorageOptions<T>> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET
    if (!isString(options.key)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "key"))
      return
    }

    try {
      const { data, dataType } = dataToDataType(options.data)
      invoke<SuccessResult<U>>(event, { key: options.key, data, dataType }, result => {
        invokeCallback(event, options, result)
      })
    } catch (error) {
      invokeFailure(event, options, (error as Error).message)
    }
  }, options)
}

export function setStorageSync<T = any>(key: string, data: T) {
  const event = Events.SET_SYNC
  if (!isString(key)) {
    return
  }
  try {
    const { data: dataString, dataType } = dataToDataType(data)
    const { errMsg } = globalThis.__NZAppServiceNativeSDK.storage.setStorageSync(
      key,
      dataString,
      dataType
    )
    if (errMsg) {
      return
    }
  } catch (error) {
    throw new Error(`${event}:fail ${(error as Error).message}`)
  }
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

export function removeStorage<T extends RemoveStorageOptions = RemoveStorageOptions>(
  options: T
): AsyncReturn<T, RemoveStorageOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.REMOVE
    if (!isString(options.key)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "key"))
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

export function removeStorageSync(key: string) {
  const event = Events.REMOVE_SYNC
  if (!isString(key)) {
    return
  }
  const { errMsg } = globalThis.__NZAppServiceNativeSDK.storage.removeStorageSync(key)
  if (errMsg) {
    throw new Error(`${event}:fail ${errMsg}`)
  }
}

interface ClearStorageOptions {
  success?: ClearStorageSuccessCallback
  fail?: ClearStorageFailCallback
  complete?: ClearStorageCompleteCallback
}

type ClearStorageSuccessCallback = (res: GeneralCallbackResult) => void

type ClearStorageFailCallback = (res: GeneralCallbackResult) => void

type ClearStorageCompleteCallback = (res: GeneralCallbackResult) => void

export function clearStorage<T extends ClearStorageOptions = ClearStorageOptions>(
  options: T
): AsyncReturn<T, ClearStorageOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.CLEAR
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

export function clearStorageSync() {
  const event = Events.CLEAR_SYNC
  const { errMsg } = globalThis.__NZAppServiceNativeSDK.storage.clearStorageSync()
  if (errMsg) {
    throw new Error(`${event}:fail ${errMsg}`)
  }
}

interface GetStorageInfoOptions {
  success?: GetStorageInfoSuccessCallback
  fail?: GetStorageInfoFailCallback
  complete?: GetStorageInfoCompleteCallback
}

export interface GetStorageInfoSuccessCallbackResult {
  keys: string[]
  currentSize: number
  limitSize: number
  errMsg: string
}

type GetStorageInfoSuccessCallback = (res: GetStorageInfoSuccessCallbackResult) => void

type GetStorageInfoFailCallback = (res: GeneralCallbackResult) => void

type GetStorageInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getStorageInfo<T extends GetStorageInfoOptions = GetStorageInfoOptions>(
  options: T
): AsyncReturn<T, GetStorageInfoOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.INFO
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

export function getStorageInfoSync(): GetStorageInfoSuccessCallbackResult {
  const event = Events.INFO_SYNC
  const { errMsg, result } = globalThis.__NZAppServiceNativeSDK.storage.getStorageInfoSync()
  if (errMsg) {
    throw new Error(`${event}:fail ${errMsg}`)
  }
  return result
}
