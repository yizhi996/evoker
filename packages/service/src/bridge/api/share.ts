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
  /** 接口调用成功的回调函数 */
  success?: ShowShareMenuSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowShareMenuFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowShareMenuCompleteCallback
}

type ShowShareMenuSuccessCallback = (res: GeneralCallbackResult) => void

type ShowShareMenuFailCallback = (res: GeneralCallbackResult) => void

type ShowShareMenuCompleteCallback = (res: GeneralCallbackResult) => void

/** 允许当前页面的分享按钮可以点击 */
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
  /** 接口调用成功的回调函数 */
  success?: HideShareMenuSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideShareMenuFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideShareMenuCompleteCallback
}

type HideShareMenuSuccessCallback = (res: GeneralCallbackResult) => void

type HideShareMenuFailCallback = (res: GeneralCallbackResult) => void

type HideShareMenuCompleteCallback = (res: GeneralCallbackResult) => void

/** 禁用当前页面的分享按钮 */
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
