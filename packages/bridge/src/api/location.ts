import { invoke, subscribe } from "../bridge"
import {
  AsyncReturn,
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI
} from "../async"
import { addEvent, removeEvent, dispatchEvent } from "@evoker/shared"

const enum Events {
  GET_LOCATION = "getLocation",
  START_LOCATION_UPDATE = "startLocationUpdate",
  STOP_LOCATION_UPDATE = "stopLocationUpdate"
}

interface GetLocationOptions {
  type?: "wgs84" | "gcj02"
  altitude?: boolean
  isHighAccuracy?: boolean
  highAccuracyExpireTime?: number
  /** 接口调用成功的回调函数 */
  success?: GetLocationSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetLocationFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetLocationCompleteCallback
}

interface GetLocationSuccessCallbackResult {
  latitude: number
  longitude: number
  speed: number
  accuracy: number
  altitude: number
  verticalAccuracy: number
  horizontalAccuracy: number
}

type GetLocationSuccessCallback = (res: GetLocationSuccessCallbackResult) => void

type GetLocationFailCallback = (res: GeneralCallbackResult) => void

type GetLocationCompleteCallback = (res: GeneralCallbackResult) => void

export function getLocation<T extends GetLocationOptions = GetLocationOptions>(
  options: T
): AsyncReturn<T, GetLocationOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.GET_LOCATION
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { type: "wgs84", altitude: false, isHighAccuracy: false }
  )
}

interface StartLocationUpdateOptions {
  type?: "wgs84" | "gcj02"
  /** 接口调用成功的回调函数 */
  success?: StartLocationUpdateSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: StartLocationUpdateFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: StartLocationUpdateCompleteCallback
}

type StartLocationUpdateSuccessCallback = (res: GeneralCallbackResult) => void

type StartLocationUpdateFailCallback = (res: GeneralCallbackResult) => void

type StartLocationUpdateCompleteCallback = (res: GeneralCallbackResult) => void

export function startLocationUpdate<
  T extends StartLocationUpdateOptions = StartLocationUpdateOptions
>(options: T): AsyncReturn<T, StartLocationUpdateOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.START_LOCATION_UPDATE
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { type: "gcj02" }
  )
}

interface StopLocationUpdateOptions {
  /** 接口调用成功的回调函数 */
  success?: StopLocationUpdateSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: StopLocationUpdateFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: StopLocationUpdateCompleteCallback
}

type StopLocationUpdateSuccessCallback = (res: GeneralCallbackResult) => void

type StopLocationUpdateFailCallback = (res: GeneralCallbackResult) => void

type StopLocationUpdateCompleteCallback = (res: GeneralCallbackResult) => void

export function stopLocationUpdate<T extends StopLocationUpdateOptions = StopLocationUpdateOptions>(
  options: T
): AsyncReturn<T, StopLocationUpdateOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.STOP_LOCATION_UPDATE
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

const ON_LOCATION_CHANGE = "MODULE_LOCATION_ON_CHANGE"

const ON_LOCATION_CHANGE_ERROR = "MODULE_LOCATION_ON_CHANGE_ERROR"

subscribe(ON_LOCATION_CHANGE, result => {
  dispatchEvent(ON_LOCATION_CHANGE, result)
})

subscribe(ON_LOCATION_CHANGE_ERROR, result => {
  dispatchEvent(ON_LOCATION_CHANGE_ERROR, result)
})

type OnLocationChangeCallback = (res: GetLocationSuccessCallbackResult) => void

export function onLocationChange(callback: OnLocationChangeCallback) {
  addEvent(ON_LOCATION_CHANGE, callback)
}

export function offLocationChange(callback: () => void) {
  removeEvent(ON_LOCATION_CHANGE, callback)
}

interface OnLocationChangeErrorCallbackResult {
  errMsg: string
}

type OnLocationChangeErrorCallback = (res: OnLocationChangeErrorCallbackResult) => void

export function onLocationChangeError(callback: OnLocationChangeErrorCallback) {
  addEvent(ON_LOCATION_CHANGE_ERROR, callback)
}

export function offLocationChangeError(callback: () => void) {
  removeEvent(ON_LOCATION_CHANGE_ERROR, callback)
}
