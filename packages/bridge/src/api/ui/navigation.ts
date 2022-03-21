import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  SET_NAVIGATION_BAR_TITLE = "setNavigationBarTitle",
  SHOW_NAVIGATION_BAR_LOADING = "showNavigationBarLoading",
  HIDE_NAVIGATION_BAR_LOADING = "hideNavigationBarLoading",
  SET_NAVIGATION_BAR_COLOR = "setNavigationBarColor",
  HIDE_HOMM_BUTTON = "hideHomeButton"
}

interface ShowNavigationBarLoadingOptions {
  success?: ShowNavigationBarLoadingSuccessCallback
  fail?: ShowNavigationBarLoadingFailCallback
  complete?: ShowNavigationBarLoadingCompleteCallback
}

type ShowNavigationBarLoadingSuccessCallback = (
  res: GeneralCallbackResult
) => void

type ShowNavigationBarLoadingFailCallback = (res: GeneralCallbackResult) => void

type ShowNavigationBarLoadingCompleteCallback = (
  res: GeneralCallbackResult
) => void

export function showNavigationBarLoading<
  T extends ShowNavigationBarLoadingOptions = ShowNavigationBarLoadingOptions
>(options: T): AsyncReturn<T, ShowNavigationBarLoadingOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.SHOW_NAVIGATION_BAR_LOADING, {}, result => {
      invokeCallback(Events.SHOW_NAVIGATION_BAR_LOADING, options, result)
    })
  }, options)
}

interface HideNavigationBarLoadingOptions {
  success?: HideNavigationBarLoadingSuccessCallback
  fail?: HideNavigationBarLoadingFailCallback
  complete?: HideNavigationBarLoadingCompleteCallback
}

type HideNavigationBarLoadingSuccessCallback = (
  res: GeneralCallbackResult
) => void

type HideNavigationBarLoadingFailCallback = (res: GeneralCallbackResult) => void

type HideNavigationBarLoadingCompleteCallback = (
  res: GeneralCallbackResult
) => void

export function hideNavigationBarLoading<
  T extends HideNavigationBarLoadingOptions = HideNavigationBarLoadingOptions
>(options: T): AsyncReturn<T, HideNavigationBarLoadingOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.HIDE_NAVIGATION_BAR_LOADING, {}, result => {
      invokeCallback(Events.HIDE_NAVIGATION_BAR_LOADING, options, result)
    })
  }, options)
}

interface SetNavigationBarColorOptions {
  frontColor: "#ffffff" | "#000000"
  backgroundColor: string
  animation?: SetNavigationBarColorAnimation
  success?: SetNavigationBarColorSuccessCallback
  fail?: SetNavigationBarColorFailCallback
  complete?: SetNavigationBarColorCompleteCallback
}

interface SetNavigationBarColorAnimation {
  duration?: number
  timingFunc?: "linear" | "easeIn" | "easeOut" | "easeInOut"
}

type SetNavigationBarColorSuccessCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarColorFailCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarColorCompleteCallback = (
  res: GeneralCallbackResult
) => void

export function setNavigationBarColor<
  T extends SetNavigationBarColorOptions = SetNavigationBarColorOptions
>(options: T): AsyncReturn<T, SetNavigationBarColorOptions> {
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = Object.assign(
      {
        animation: {
          duration: 0,
          timingFunc: "linear"
        }
      },
      options
    )
    invoke(Events.SET_NAVIGATION_BAR_COLOR, finalOptions, result => {
      invokeCallback(Events.SET_NAVIGATION_BAR_COLOR, finalOptions, result)
    })
  }, options)
}

interface SetNavigationBarTitleOptions {
  title: string
  success?: SetNavigationBarTitleSuccessCallback
  fail?: SetNavigationBarTitleFailCallback
  complete?: SetNavigationBarTitleCompleteCallback
}

type SetNavigationBarTitleSuccessCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarTitleFailCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarTitleCompleteCallback = (
  res: GeneralCallbackResult
) => void

export function setNavigationBarTitle<
  T extends SetNavigationBarTitleOptions = SetNavigationBarTitleOptions
>(options: T): AsyncReturn<T, SetNavigationBarTitleOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(
      Events.SET_NAVIGATION_BAR_TITLE,
      { title: options.title ?? "" },
      result => {
        invokeCallback(Events.SET_NAVIGATION_BAR_TITLE, options, result)
      }
    )
  }, options)
}

interface HideHomeButtonOptions {
  success?: HideHomeButtonSuccessCallback
  fail?: HideHomeButtonFailCallback
  complete?: HideHomeButtonCompleteCallback
}

type HideHomeButtonSuccessCallback = (res: GeneralCallbackResult) => void

type HideHomeButtonFailCallback = (res: GeneralCallbackResult) => void

type HideHomeButtonCompleteCallback = (res: GeneralCallbackResult) => void

export function hideHomeButton<
  T extends HideHomeButtonOptions = HideHomeButtonOptions
>(options: T): AsyncReturn<T, HideHomeButtonOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.HIDE_HOMM_BUTTON, {}, result => {
      invokeCallback(Events.HIDE_HOMM_BUTTON, options, result)
    })
  }, options)
}
