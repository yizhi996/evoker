import { isString, isNumber, clamp, addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"
import { invoke, subscribe } from "../../bridge"
import {
  invokeFailure,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

const enum Events {
  GET_SCREEN_BRIGHTNESS = "getScreenBrightness",
  SET_SCREEN_BRIGHTNESS = "setScreenBrightness",
  SET_KEEP_SCREEN_ON = "setKeepScreenOn",
  ON_USER_CAPTURE_SCREEN = "APP_USER_CAPTURE_SCREEN"
}

interface GetScreenBrightnessOptions {
  success?: GetScreenBrightnessSuccessCallback
  fail?: GetScreenBrightnessFailCallback
  complete?: GetScreenBrightnessCompleteCallback
}

interface GetScreenBrightnessSuccessCallbackResult {
  value: number
}

type GetScreenBrightnessSuccessCallback = (res: GetScreenBrightnessSuccessCallbackResult) => void

type GetScreenBrightnessFailCallback = (res: GeneralCallbackResult) => void

type GetScreenBrightnessCompleteCallback = (res: GeneralCallbackResult) => void

export function getScreenBrightness<
  T extends GetScreenBrightnessOptions = GetScreenBrightnessOptions
>(options: T): AsyncReturn<T, GetScreenBrightnessOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.GET_SCREEN_BRIGHTNESS
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface SetScreenBrightnessOptions {
  value: number
  success?: SetScreenBrightnessSuccessCallback
  fail?: SetScreenBrightnessFailCallback
  complete?: SetScreenBrightnessCompleteCallback
}

type SetScreenBrightnessSuccessCallback = (res: GeneralCallbackResult) => void

type SetScreenBrightnessFailCallback = (res: GeneralCallbackResult) => void

type SetScreenBrightnessCompleteCallback = (res: GeneralCallbackResult) => void

export function setScreenBrightness<
  T extends SetScreenBrightnessOptions = SetScreenBrightnessOptions
>(options: T): AsyncReturn<T, SetScreenBrightnessOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SET_SCREEN_BRIGHTNESS
    let value = options.value
    if (isString(value)) {
      value = parseFloat(value)
    }
    if (isNaN(value) || !isNumber(value)) {
      invokeFailure(event, options, "value invalid")
      return
    }
    value = clamp(value, 0, 1)
    invoke<SuccessResult<T>>(event, { value }, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface SetKeepScreenOnOptions {
  keepScreenOn: boolean
  success?: SetKeepScreenOnSuccessCallback
  fail?: SetKeepScreenOnFailCallback
  complete?: SetKeepScreenOnCompleteCallback
}

type SetKeepScreenOnSuccessCallback = (res: GeneralCallbackResult) => void

type SetKeepScreenOnFailCallback = (res: GeneralCallbackResult) => void

type SetKeepScreenOnCompleteCallback = (res: GeneralCallbackResult) => void

export function setKeepScreenOn<T extends SetKeepScreenOnOptions = SetKeepScreenOnOptions>(
  options: T
): AsyncReturn<T, SetKeepScreenOnOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SET_KEEP_SCREEN_ON
    invoke<SuccessResult<T>>(event, { keepScreenOn: options.keepScreenOn }, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

type OnUserCaptureScreenCallback = (result: GeneralCallbackResult) => void

subscribe(Events.ON_USER_CAPTURE_SCREEN, result => {
  dispatchEvent(Events.ON_USER_CAPTURE_SCREEN, result)
})

export function onUserCaptureScreen(callback: OnUserCaptureScreenCallback) {
  addEvent(Events.ON_USER_CAPTURE_SCREEN, callback)
}

export function offUserCaptureScreen(callback: () => void) {
  removeEvent(Events.ON_USER_CAPTURE_SCREEN, callback)
}
