import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import {
  ERR_CANNOT_EMPTY,
  ERR_INVALID_ARG_VALUE,
  ERR_INVALID_ARG_TYPE
} from "../../errors"

const enum Events {
  SHORT = "vibrateShort",
  LONG = "vibrateLong"
}

interface VibrateShortOptions {
  /** 震动强度
   *
   * 可选值：
   * - heavy: 重
   * - medium: 中等
   * - light: 轻
   */
  type: "medium" | "heavy" | "light"
  /** 接口调用成功的回调函数 */
  success?: VibrateShortSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: VibrateShortFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: VibrateShortCompleteCallback
}

type VibrateShortSuccessCallback = (res: GeneralCallbackResult) => void

type VibrateShortFailCallback = (res: GeneralCallbackResult) => void

type VibrateShortCompleteCallback = (res: GeneralCallbackResult) => void

/** 使手机发生较短时间的振动 */
export function vibrateShort<T extends VibrateShortOptions = VibrateShortOptions>(
  options: T
): AsyncReturn<T, VibrateShortOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SHORT
    if (!options.type) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.type", options.type, ERR_CANNOT_EMPTY)
      )
      return
    }

    const validTypes = ["heavy", "medium", "light"]
    if (!validTypes.includes(options.type)) {
      invokeFailure(event, options, ERR_INVALID_ARG_TYPE("options.type", validTypes, options.type))
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface VibrateLongOptions {
  /** 接口调用成功的回调函数 */
  success?: VibrateLongSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: VibrateLongFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: VibrateLongCompleteCallback
}

type VibrateLongSuccessCallback = (res: GeneralCallbackResult) => void

type VibrateLongFailCallback = (res: GeneralCallbackResult) => void

type VibrateLongCompleteCallback = (res: GeneralCallbackResult) => void

/** 使手机发生较长时间的振动（嗡） */
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
