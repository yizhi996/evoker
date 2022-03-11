import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  SetNavigationBarTitle = "setNavigationBarTitle",
  ShowNavigationBarLoading = "showNavigationBarLoading",
  HideNavigationBarLoading = "hideNavigationBarLoading",
  SetNavigationBarColor = "setNavigationBarColor",
  HideHomeButton = "hideHomeButton"
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
    invoke<SuccessResult<T>>(Events.ShowNavigationBarLoading, {}, result => {
      invokeCallback(Events.ShowNavigationBarLoading, options, result)
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
    invoke<SuccessResult<T>>(Events.HideNavigationBarLoading, {}, result => {
      invokeCallback(Events.HideNavigationBarLoading, options, result)
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
    invoke(Events.SetNavigationBarColor, finalOptions, result => {
      invokeCallback(Events.SetNavigationBarColor, finalOptions, result)
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
      Events.SetNavigationBarTitle,
      { title: options.title ?? "" },
      result => {
        invokeCallback(Events.SetNavigationBarTitle, options, result)
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
    invoke<SuccessResult<T>>(Events.HideHomeButton, {}, result => {
      invokeCallback(Events.HideHomeButton, options, result)
    })
  }, options)
}
