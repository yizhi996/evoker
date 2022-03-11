import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  GetScreenBrightness = "getScreenBrightness",
  SetScreenBrightness = "setScreenBrightness",
  SetKeepScreenOn = "setKeepScreenOn"
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
    invoke<SuccessResult<T>>(Events.GetScreenBrightness, {}, result => {
      invokeCallback(Events.GetScreenBrightness, options, result)
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
    if (value < 0) {
      value = 0
    } else if (value > 1) {
      value = 1
    }
    invoke<SuccessResult<T>>(Events.SetScreenBrightness, { value }, result => {
      invokeCallback(Events.SetScreenBrightness, options, result)
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

export function setKeepScreenOn<
  T extends SetKeepScreenOnOptions = SetKeepScreenOnOptions
>(options: T): AsyncReturn<T, SetKeepScreenOnOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(
      Events.SetKeepScreenOn,
      { keepScreenOn: options.keepScreenOn },
      result => {
        invokeCallback(Events.SetKeepScreenOn, options, result)
      }
    )
  }, options)
}
