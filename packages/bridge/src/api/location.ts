import { invoke, subscribe } from "../bridge"
import {
  AsyncReturn,
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI
} from "../async"
import { addEvent, removeEvent, dispatchEvent, extend } from "@nzoth/shared"

const enum Events {
  GET_LOCATION = "getLocation",
  START_LOCATION_UPDATE = "startLocationUpdate",
  STOP_LOCATION_UPDATE = "stopLocationUpdate",
  ON_LOCATION_CHANGE = "APP_LOCATION_ON_CHANGE"
}

interface GetLocationOptions {
  type?: "wgs84" | "gcj02"
  altitude?: boolean
  isHighAccuracy?: boolean
  highAccuracyExpireTime?: number
  success?: GetLocationSuccessCallback
  fail?: GetLocationFailCallback
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
  return wrapperAsyncAPI<T>(options => {
    const event = Events.GET_LOCATION
    invoke<SuccessResult<T>>(
      event,
      extend({ type: "wgs84", altitude: false, isHighAccuracy: false }, options),
      result => {
        invokeCallback(event, options, result)
      }
    )
  }, options)
}

interface StartLocationUpdateOptions {
  type?: "wgs84" | "gcj02"
  success?: StartLocationUpdateSuccessCallback
  fail?: StartLocationUpdateFailCallback
  complete?: StartLocationUpdateCompleteCallback
}

type StartLocationUpdateSuccessCallback = (res: GeneralCallbackResult) => void

type StartLocationUpdateFailCallback = (res: GeneralCallbackResult) => void

type StartLocationUpdateCompleteCallback = (res: GeneralCallbackResult) => void

export function startLocationUpdate<
  T extends StartLocationUpdateOptions = StartLocationUpdateOptions
>(options: T): AsyncReturn<T, StartLocationUpdateOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.START_LOCATION_UPDATE
    invoke<SuccessResult<T>>(event, { type: options.type || "gcj02" }, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface StopLocationUpdateOptions {
  success?: StopLocationUpdateSuccessCallback
  fail?: StopLocationUpdateFailCallback
  complete?: StopLocationUpdateCompleteCallback
}

type StopLocationUpdateSuccessCallback = (res: GeneralCallbackResult) => void

type StopLocationUpdateFailCallback = (res: GeneralCallbackResult) => void

type StopLocationUpdateCompleteCallback = (res: GeneralCallbackResult) => void

export function stopLocationUpdate<T extends StopLocationUpdateOptions = StopLocationUpdateOptions>(
  options: T
): AsyncReturn<T, StopLocationUpdateOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.STOP_LOCATION_UPDATE
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

subscribe(Events.ON_LOCATION_CHANGE, result => {
  dispatchEvent(Events.ON_LOCATION_CHANGE, result)
})

type OnLocationChangeCallback = (res: GetLocationSuccessCallbackResult) => void

export function onLocationChange(callback: OnLocationChangeCallback) {
  addEvent(Events.ON_LOCATION_CHANGE, callback)
}

export function offLocationChange(callback: () => void) {
  removeEvent(Events.ON_LOCATION_CHANGE, callback)
}
