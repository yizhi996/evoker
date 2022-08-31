import { isNumber, clamp, addEvent, removeEvent, dispatchEvent } from "@evoker/shared"
import { isString } from "@vue/shared"
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
  /** 接口调用成功的回调函数 */
  success?: GetScreenBrightnessSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetScreenBrightnessFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetScreenBrightnessCompleteCallback
}

interface GetScreenBrightnessSuccessCallbackResult {
  /** 屏幕亮度值，范围 0 ~ 1，0 最暗，1 最亮 */
  value: number
}

type GetScreenBrightnessSuccessCallback = (res: GetScreenBrightnessSuccessCallbackResult) => void

type GetScreenBrightnessFailCallback = (res: GeneralCallbackResult) => void

type GetScreenBrightnessCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取屏幕亮度 */
export function getScreenBrightness<
  T extends GetScreenBrightnessOptions = GetScreenBrightnessOptions
>(options: T): AsyncReturn<T, GetScreenBrightnessOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_SCREEN_BRIGHTNESS
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface SetScreenBrightnessOptions {
  /** 屏幕亮度值，范围 0 ~ 1，0 最暗，1 最亮 */
  value: number
  /** 接口调用成功的回调函数 */
  success?: SetScreenBrightnessSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetScreenBrightnessFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetScreenBrightnessCompleteCallback
}

type SetScreenBrightnessSuccessCallback = (res: GeneralCallbackResult) => void

type SetScreenBrightnessFailCallback = (res: GeneralCallbackResult) => void

type SetScreenBrightnessCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置屏幕亮度 */
export function setScreenBrightness<
  T extends SetScreenBrightnessOptions = SetScreenBrightnessOptions
>(options: T): AsyncReturn<T, SetScreenBrightnessOptions> {
  return wrapperAsyncAPI(options => {
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
  /** 是否保持屏幕常亮 */
  keepScreenOn: boolean
  /** 接口调用成功的回调函数 */
  success?: SetKeepScreenOnSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetKeepScreenOnFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetKeepScreenOnCompleteCallback
}

type SetKeepScreenOnSuccessCallback = (res: GeneralCallbackResult) => void

type SetKeepScreenOnFailCallback = (res: GeneralCallbackResult) => void

type SetKeepScreenOnCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置是否保持常亮状态。仅在当前小程序生效，离开小程序后设置失效 */
export function setKeepScreenOn<T extends SetKeepScreenOnOptions = SetKeepScreenOnOptions>(
  options: T
): AsyncReturn<T, SetKeepScreenOnOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET_KEEP_SCREEN_ON
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

type OnUserCaptureScreenCallback = (result: GeneralCallbackResult) => void

subscribe(Events.ON_USER_CAPTURE_SCREEN, result => {
  dispatchEvent(Events.ON_USER_CAPTURE_SCREEN, result)
})

/** 监听用户主动截屏事件 */
export function onUserCaptureScreen(
  /** 用户主动截屏事件的回调函数 */
  callback: OnUserCaptureScreenCallback
) {
  addEvent(Events.ON_USER_CAPTURE_SCREEN, callback)
}

/** 取消监听用户主动截屏事件 */
export function offUserCaptureScreen(
  /** 用户主动截屏事件的回调函数 */
  callback: OnUserCaptureScreenCallback
) {
  removeEvent(Events.ON_USER_CAPTURE_SCREEN, callback)
}
