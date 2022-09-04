import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import { ERR_INVALID_ARG_TYPE } from "../../errors"
import { isNumber } from "@evoker/shared"

const enum Events {
  SET = "setVolume",
  GET = "getVolume"
}

interface SetVolumeOptions {
  /** 音量 0 ~ 1 */
  volume: number
  /** 接口调用成功的回调函数 */
  success?: SetVolumeSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetVolumeFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetVolumeCompleteCallback
}

type SetVolumeSuccessCallback = (res: GeneralCallbackResult) => void

type SetVolumeFailCallback = (res: GeneralCallbackResult) => void

type SetVolumeCompleteCallback = (res: GeneralCallbackResult) => void

export function setVolume<T extends SetVolumeOptions = SetVolumeOptions>(
  options: T
): AsyncReturn<T, SetVolumeOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET

    if (!isNumber(options.volume)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.volume", "number", options.volume)
      )
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetVolumeOptions {
  /** 接口调用成功的回调函数 */
  success?: GetVolumeSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetVolumeFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetVolumeCompleteCallback
}

interface GetVolumeSuccessCallbackResult {
  /** 音量 0 ~ 1 */
  volume: number
}

type GetVolumeSuccessCallback = (res: GetVolumeSuccessCallbackResult) => void

type GetVolumeFailCallback = (res: GeneralCallbackResult) => void

type GetVolumeCompleteCallback = (res: GeneralCallbackResult) => void

export function getVolume<T extends GetVolumeOptions = GetVolumeOptions>(
  options: T
): AsyncReturn<T, GetVolumeOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
