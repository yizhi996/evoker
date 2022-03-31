import { isString } from "@nzoth/shared"
import { invoke } from "../../bridge"
import {
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { showToast } from "../ui/interaction"

const enum Events {
  GET_CLIPBOARD_DATA = "getClipboardData",
  SET_CLIPBOARD_DATA = "setClipboardData"
}

interface GetClipboardDataOptions {
  success?: GetClipboardDataSuccessCallback
  fail?: GetClipboardDataFailCallback
  complete?: GetClipboardDataCompleteCallback
}

interface GetClipboardDataSuccessCallbackResult {
  data: string
}

type GetClipboardDataSuccessCallback = (
  res: GetClipboardDataSuccessCallbackResult
) => void

type GetClipboardDataFailCallback = (res: GeneralCallbackResult) => void

type GetClipboardDataCompleteCallback = (res: GeneralCallbackResult) => void

export function getClipboardData<
  T extends GetClipboardDataOptions = GetClipboardDataOptions
>(options: T): AsyncReturn<T, GetClipboardDataOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.GET_CLIPBOARD_DATA, {}, result => {
      if (result.errMsg) {
        invokeFailure(Events.GET_CLIPBOARD_DATA, options, result.errMsg)
        return
      } else {
        invokeSuccess(Events.GET_CLIPBOARD_DATA, options, result.data)
        showToast({
          title: `“${globalThis.__NZConfig.appName}” 读取了你的剪切板内容`,
          icon: "none",
          duration: 1500
        })
      }
    })
  }, options)
}

interface SetClipboardDataOptions {
  data: string
  success?: SetClipboardDataSuccessCallback
  fail?: SetClipboardDataFailCallback
  complete?: SetClipboardDataCompleteCallback
}

type SetClipboardDataSuccessCallback = (res: GeneralCallbackResult) => void

type SetClipboardDataFailCallback = (res: GeneralCallbackResult) => void

type SetClipboardDataCompleteCallback = (res: GeneralCallbackResult) => void

export function setClipboardData<
  T extends SetClipboardDataOptions = SetClipboardDataOptions
>(options: T): AsyncReturn<T, SetClipboardDataOptions> {
  return wrapperAsyncAPI<T>(options => {
    if (!isString(options.data)) {
      invokeFailure(
        Events.SET_CLIPBOARD_DATA,
        options,
        "data type require string"
      )
    }
    invoke<SuccessResult<T>>(Events.SET_CLIPBOARD_DATA, options, result => {
      if (result.errMsg) {
        invokeFailure(Events.SET_CLIPBOARD_DATA, options, result.errMsg)
        return
      } else {
        invokeSuccess(Events.SET_CLIPBOARD_DATA, options, result.data)
        showToast({ title: "内容已复制", icon: "none", duration: 1500 })
      }
    })
  }, options)
}
