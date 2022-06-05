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

type GetBatteryInfoSuccessCallback = (res: GetBatteryInfoSuccessCallbackResult) => void

type GetBatteryInfoFailCallback = (res: GeneralCallbackResult) => void

type GetBatteryInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getBatteryInfo<T extends GetBatteryInfoOptions = GetBatteryInfoOptions>(
  options: T
): AsyncReturn<T, GetBatteryInfoOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_BATTERY_INFO
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
