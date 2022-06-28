import { isString } from "@vue/shared"
import { invoke } from "../../bridge"
import {
  invokeSuccess,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { showToast } from "../ui/interaction"
import { ErrorCodes, errorMessage } from "../../errors"

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

type GetClipboardDataSuccessCallback = (res: GetClipboardDataSuccessCallbackResult) => void

type GetClipboardDataFailCallback = (res: GeneralCallbackResult) => void

type GetClipboardDataCompleteCallback = (res: GeneralCallbackResult) => void

export function getClipboardData<T extends GetClipboardDataOptions = GetClipboardDataOptions>(
  options: T
): AsyncReturn<T, GetClipboardDataOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_CLIPBOARD_DATA
    invoke<SuccessResult<T>>(event, options, result => {
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
        return
      } else {
        invokeSuccess(event, options, result.data)
        showToast({
          title: `“${globalThis.__Config.appName}” 读取了你的剪切板内容`,
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

export function setClipboardData<T extends SetClipboardDataOptions = SetClipboardDataOptions>(
  options: T
): AsyncReturn<T, SetClipboardDataOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET_CLIPBOARD_DATA
    if (!isString(options.data)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "data"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
        return
      } else {
        invokeSuccess(event, options, result.data)
        showToast({ title: "内容已复制", icon: "none", duration: 1500 })
      }
    })
  }, options)
}
