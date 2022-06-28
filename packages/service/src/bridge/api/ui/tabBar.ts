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
  animation?: boolean
  success?: ShowTabBarSuccessCallback
  fail?: ShowTabBarFailCallback
  complete?: ShowTabBarCompleteCallback
}

type ShowTabBarSuccessCallback = (res: GeneralCallbackResult) => void

type ShowTabBarFailCallback = (res: GeneralCallbackResult) => void

type ShowTabBarCompleteCallback = (res: GeneralCallbackResult) => void

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
  animation?: boolean
  success?: HideTabBarSuccessCallback
  fail?: HideTabBarFailCallback
  complete?: HideTabBarCompleteCallback
}

type HideTabBarSuccessCallback = (res: GeneralCallbackResult) => void

type HideTabBarFailCallback = (res: GeneralCallbackResult) => void

type HideTabBarCompleteCallback = (res: GeneralCallbackResult) => void

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
