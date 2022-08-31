import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure,
  AuthSetting
} from "@evoker/bridge"
import { innerAppData } from "../../app"

const enum Events {
  OPEN_SETTING = "openSetting"
}

interface OpenSettingOptions {
  /** 接口调用成功的回调函数 */
  success?: OpenSettingSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: OpenSettingFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: OpenSettingCompleteCallback
}

interface OpenSettingSuccessCallbackResult {
  authSetting: AuthSetting
}

type OpenSettingSuccessCallback = (res: OpenSettingSuccessCallbackResult) => void

type OpenSettingFailCallback = (res: GeneralCallbackResult) => void

type OpenSettingCompleteCallback = (res: GeneralCallbackResult) => void

export function openSetting<T extends OpenSettingOptions = OpenSettingOptions>(
  options: T
): AsyncReturn<T, OpenSettingOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.OPEN_SETTING
    if (!innerAppData.eventFromUserClick) {
      invokeFailure(event, options, "can only be invoked by user click gesture.")
      return
    }
    InnerJSBridge.invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
