import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure,
  AuthSetting
} from "@nzoth/bridge"
import { innerAppData } from "../../app"

const enum Events {
  OPEN_SETTING = "openSetting"
}

interface OpenSettingOptions {
  success?: OpenSettingSuccessCallback
  fail?: OpenSettingFailCallback
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
  return wrapperAsyncAPI<T>(options => {
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
