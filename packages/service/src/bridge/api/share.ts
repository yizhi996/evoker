import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn
} from "@evoker/bridge"
import { extend } from "@vue/shared"
import { innerAppData } from "../../app"

const enum Events {
  SHOW_SHARE_MENU = "showShareMenu",
  HIDE_SHARE_MENU = "hideShareMenu"
}

interface ShowShareMenuOptions {
  success?: ShowShareMenuSuccessCallback
  fail?: ShowShareMenuFailCallback
  complete?: ShowShareMenuCompleteCallback
}

type ShowShareMenuSuccessCallback = (res: GeneralCallbackResult) => void

type ShowShareMenuFailCallback = (res: GeneralCallbackResult) => void

type ShowShareMenuCompleteCallback = (res: GeneralCallbackResult) => void

export function showShareMenu<T extends ShowShareMenuOptions = ShowShareMenuOptions>(
  options: T
): AsyncReturn<T, ShowShareMenuOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SHOW_SHARE_MENU
    InnerJSBridge.invoke<SuccessResult<T>>(
      event,
      extend({ route: innerAppData.lastRoute }, options),
      result => {
        invokeCallback(event, options, result)
      }
    )
  }, options)
}

interface HideShareMenuOptions {
  success?: HideShareMenuSuccessCallback
  fail?: HideShareMenuFailCallback
  complete?: HideShareMenuCompleteCallback
}

type HideShareMenuSuccessCallback = (res: GeneralCallbackResult) => void

type HideShareMenuFailCallback = (res: GeneralCallbackResult) => void

type HideShareMenuCompleteCallback = (res: GeneralCallbackResult) => void

export function hideShareMenu<T extends HideShareMenuOptions = HideShareMenuOptions>(
  options: T
): AsyncReturn<T, HideShareMenuOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.HIDE_SHARE_MENU
    InnerJSBridge.invoke<SuccessResult<T>>(
      event,
      extend({ route: innerAppData.lastRoute }, options),
      result => {
        invokeCallback(event, options, result)
      }
    )
  }, options)
}
