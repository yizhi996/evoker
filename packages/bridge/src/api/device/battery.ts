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
  /** 接口调用成功的回调函数 */
  success?: GetBatteryInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetBatteryInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetBatteryInfoCompleteCallback
}

interface GetBatteryInfoSuccessCallbackResult {
  /** 设备电量，范围 1 - 100 */
  level: number
  /** 是否正在充电中 */
  isCharging: boolean
}

type GetBatteryInfoSuccessCallback = (res: GetBatteryInfoSuccessCallbackResult) => void

type GetBatteryInfoFailCallback = (res: GeneralCallbackResult) => void

type GetBatteryInfoCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取设备电量 */
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
