import { isString, isNumber } from "@nzoth/shared"
import { invoke, subscribe } from "../../bridge"
import {
  invokeFailure,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { onEvent, offEvent, emitEvent } from "../../event"

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

type GetScreenBrightnessSuccessCallback = (
  res: GetScreenBrightnessSuccessCallbackResult
) => void

type GetScreenBrightnessFailCallback = (res: GeneralCallbackResult) => void

type GetScreenBrightnessCompleteCallback = (res: GeneralCallbackResult) => void

export function getScreenBrightness<
  T extends GetScreenBrightnessOptions = GetScreenBrightnessOptions
>(options: T): AsyncReturn<T, GetScreenBrightnessOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.GET_SCREEN_BRIGHTNESS, {}, result => {
      invokeCallback(Events.GET_SCREEN_BRIGHTNESS, options, result)
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
    let value = options.value
    if (isString(value)) {
      value = parseFloat(value)
    }
    if (isNaN(value) || !isNumber(value)) {
      invokeFailure(Events.SET_SCREEN_BRIGHTNESS, options, "value invalid")
      return
    }
    value = Math.min(Math.max(0, value), 1)
    invoke<SuccessResult<T>>(
      Events.SET_SCREEN_BRIGHTNESS,
      { value },
      result => {
        invokeCallback(Events.SET_SCREEN_BRIGHTNESS, options, result)
      }
    )
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

export function setKeepScreenOn<
  T extends SetKeepScreenOnOptions = SetKeepScreenOnOptions
>(options: T): AsyncReturn<T, SetKeepScreenOnOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(
      Events.SET_KEEP_SCREEN_ON,
      { keepScreenOn: options.keepScreenOn },
      result => {
        invokeCallback(Events.SET_KEEP_SCREEN_ON, options, result)
      }
    )
  }, options)
}

type OnUserCaptureScreenCallback = (result: GeneralCallbackResult) => void

subscribe(Events.ON_USER_CAPTURE_SCREEN, result => {
  emitEvent(Events.ON_USER_CAPTURE_SCREEN, result)
})

export function onUserCaptureScreen(callback: OnUserCaptureScreenCallback) {
  onEvent(Events.ON_USER_CAPTURE_SCREEN, callback)
}

export function offUserCaptureScreen(callback: () => void) {
  offEvent(Events.ON_USER_CAPTURE_SCREEN, callback)
}
