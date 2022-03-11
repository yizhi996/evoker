import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../bridge"

const enum Events {
  ShowTabBar = "showTabBar",
  HideTabBar = "hideTabBar"
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
      Events.ShowTabBar,
      { animation: options.animation ?? false },
      result => {
        invokeCallback(Events.ShowTabBar, options, result)
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
      Events.HideTabBar,
      { animation: options.animation ?? false },
      result => {
        invokeCallback(Events.HideTabBar, options, result)
      }
    )
  }, options)
}
