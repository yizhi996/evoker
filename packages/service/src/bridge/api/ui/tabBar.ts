import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure
} from "@evoker/bridge"
import { innerAppData, getCurrentWebViewId } from "../../../app"
import { pathIsTabBar } from "../route"

const enum Events {
  SHOW_TAB_BAR = "showTabBar",
  HIDE_TAB_BAR = "hideTabBar"
}

interface ShowTabBarOptions {
  /** 是否需要动画效果 */
  animation?: boolean
  /** 接口调用成功的回调函数 */
  success?: ShowTabBarSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowTabBarFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowTabBarCompleteCallback
}

type ShowTabBarSuccessCallback = (res: GeneralCallbackResult) => void

type ShowTabBarFailCallback = (res: GeneralCallbackResult) => void

type ShowTabBarCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示 Tab Bar，在非 Tab Bar 页面调用无效 */
export function showTabBar<T extends ShowTabBarOptions = ShowTabBarOptions>(
  options: T
): AsyncReturn<T, ShowTabBarOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.SHOW_TAB_BAR
      const pageId = getCurrentWebViewId()
      const page = innerAppData.pages.get(pageId)!
      if (!pathIsTabBar(page.route)) {
        invokeFailure(event, options, "current page not TabBar page")
        return
      }

      InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { animation: false }
  )
}

interface HideTabBarOptions {
  /** 是否需要动画效果 */
  animation?: boolean
  /** 接口调用成功的回调函数 */
  success?: HideTabBarSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideTabBarFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideTabBarCompleteCallback
}

type HideTabBarSuccessCallback = (res: GeneralCallbackResult) => void

type HideTabBarFailCallback = (res: GeneralCallbackResult) => void

type HideTabBarCompleteCallback = (res: GeneralCallbackResult) => void

/** 隐藏 Tab Bar，在非 Tab Bar 页面调用无效 */
export function hideTabBar<T extends HideTabBarOptions = HideTabBarOptions>(
  options: T
): AsyncReturn<T, HideTabBarOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.HIDE_TAB_BAR
      const pageId = getCurrentWebViewId()
      const page = innerAppData.pages.get(pageId)!
      if (!pathIsTabBar(page.route)) {
        invokeFailure(event, options, "current page not TabBar page")
        return
      }
      InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { animation: false }
  )
}
