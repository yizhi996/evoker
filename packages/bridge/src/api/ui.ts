import { invoke } from "../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../async"

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
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(
      Events.SHOW_TAB_BAR,
      { animation: options.animation ?? false },
      result => {
        invokeCallback(Events.SHOW_TAB_BAR, options, result)
      }
    )
  }, options)
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
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(
      Events.HIDE_TAB_BAR,
      { animation: options.animation ?? false },
      result => {
        invokeCallback(Events.HIDE_TAB_BAR, options, result)
      }
    )
  }, options)
}
