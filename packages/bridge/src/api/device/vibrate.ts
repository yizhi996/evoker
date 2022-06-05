import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import { ErrorCodes, errorMessage } from "../../errors"

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

export function vibrateShort<T extends VibrateShortOptions = VibrateShortOptions>(
  options: T
): AsyncReturn<T, VibrateShortOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SHORT
    if (!options.type) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "type"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
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
  return wrapperAsyncAPI(options => {
    const event = Events.LONG
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
