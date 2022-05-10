import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

const enum Events {
  SHORT = "vibrateShort",
  LONG = "vibrateLong"
}

interface VibrateShortOptions {
  type: "medium" | "heavy" | "light"
  success?: VibrateShortSuccessCallback
  fail?: VibrateShortFailCallback
  complete?: VibrateShortCompleteCallback
}

type VibrateShortSuccessCallback = (res: GeneralCallbackResult) => void

type VibrateShortFailCallback = (res: GeneralCallbackResult) => void

type VibrateShortCompleteCallback = (res: GeneralCallbackResult) => void

export function vibrateShort<
  T extends VibrateShortOptions = VibrateShortOptions
>(options: T): AsyncReturn<T, VibrateShortOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SHORT
    invoke<SuccessResult<T>>(event, { type: options.type }, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface VibrateLongOptions {
  success?: VibrateLongSuccessCallback
  fail?: VibrateLongFailCallback
  complete?: VibrateLongCompleteCallback
}

type VibrateLongSuccessCallback = (res: GeneralCallbackResult) => void

type VibrateLongFailCallback = (res: GeneralCallbackResult) => void

type VibrateLongCompleteCallback = (res: GeneralCallbackResult) => void

export function vibrateLong<T extends VibrateLongOptions = VibrateLongOptions>(
  options: T
): AsyncReturn<T, VibrateLongOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.LONG
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
