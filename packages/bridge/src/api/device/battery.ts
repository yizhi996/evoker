import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  GetBatteryInfo = "getBatteryInfo"
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
    invoke<SuccessResult<T>>(Events.GetBatteryInfo, {}, result => {
      invokeCallback(Events.GetBatteryInfo, options, result)
    })
  }, options)
}
