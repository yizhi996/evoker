import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

const enum Events {
  SET = "setVolume",
  GET = "getVolume"
}

interface SetVolumeOptions {
  volume: number
  success?: SetVolumeSuccessCallback
  fail?: SetVolumeFailCallback
  complete?: SetVolumeCompleteCallback
}

type SetVolumeSuccessCallback = (res: GeneralCallbackResult) => void

type SetVolumeFailCallback = (res: GeneralCallbackResult) => void

type SetVolumeCompleteCallback = (res: GeneralCallbackResult) => void

export function setVolume<T extends SetVolumeOptions = SetVolumeOptions>(
  options: T
): AsyncReturn<T, SetVolumeOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SET
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetVolumeOptions {
  success?: GetVolumeSuccessCallback
  fail?: GetVolumeFailCallback
  complete?: GetVolumeCompleteCallback
}

interface GetVolumeSuccessCallbackResult {
  volume: number
}

type GetVolumeSuccessCallback = (res: GetVolumeSuccessCallbackResult) => void

type GetVolumeFailCallback = (res: GeneralCallbackResult) => void

type GetVolumeCompleteCallback = (res: GeneralCallbackResult) => void

export function getVolume<T extends GetVolumeOptions = GetVolumeOptions>(
  options: T
): AsyncReturn<T, GetVolumeOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.GET
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
