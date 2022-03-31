import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

const enum Events {
  GET_BATTERY_INFO = "getBatteryInfo"
}

interface GetBatteryInfoOptions {
  success?: GetBatteryInfoSuccessCallback
  fail?: GetBatteryInfoFailCallback
  complete?: GetBatteryInfoCompleteCallback
}

interface GetBatteryInfoSuccessCallbackResult {
  level: number
  isCharging: boolean
}

type GetBatteryInfoSuccessCallback = (
  res: GetBatteryInfoSuccessCallbackResult
) => void

type GetBatteryInfoFailCallback = (res: GeneralCallbackResult) => void

type GetBatteryInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getBatteryInfo<
  T extends GetBatteryInfoOptions = GetBatteryInfoOptions
>(options: T): AsyncReturn<T, GetBatteryInfoOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.GET_BATTERY_INFO, {}, result => {
      invokeCallback(Events.GET_BATTERY_INFO, options, result)
    })
  }, options)
}
