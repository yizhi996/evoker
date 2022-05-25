import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import { extend } from "@nzoth/shared"

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

type ShowNavigationBarLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type ShowNavigationBarLoadingFailCallback = (res: GeneralCallbackResult) => void

type ShowNavigationBarLoadingCompleteCallback = (res: GeneralCallbackResult) => void

export function showNavigationBarLoading<
  T extends ShowNavigationBarLoadingOptions = ShowNavigationBarLoadingOptions
>(options: T): AsyncReturn<T, ShowNavigationBarLoadingOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SHOW_NAVIGATION_BAR_LOADING
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface HideNavigationBarLoadingOptions {
  success?: HideNavigationBarLoadingSuccessCallback
  fail?: HideNavigationBarLoadingFailCallback
  complete?: HideNavigationBarLoadingCompleteCallback
}

type HideNavigationBarLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type HideNavigationBarLoadingFailCallback = (res: GeneralCallbackResult) => void

type HideNavigationBarLoadingCompleteCallback = (res: GeneralCallbackResult) => void

export function hideNavigationBarLoading<
  T extends HideNavigationBarLoadingOptions = HideNavigationBarLoadingOptions
>(options: T): AsyncReturn<T, HideNavigationBarLoadingOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.HIDE_NAVIGATION_BAR_LOADING
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
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

type SetNavigationBarColorCompleteCallback = (res: GeneralCallbackResult) => void

export function setNavigationBarColor<
  T extends SetNavigationBarColorOptions = SetNavigationBarColorOptions
>(options: T): AsyncReturn<T, SetNavigationBarColorOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SET_NAVIGATION_BAR_COLOR
    if (!options.frontColor) {
      invokeFailure(event, options, "required field frontColor")
      return
    }
    if (!["#ffffff", "#000000"].includes(options.frontColor)) {
      invokeFailure(event, options, "frontColor valid value: #ffffff, #000000")
      return
    }
    if (!options.backgroundColor) {
      invokeFailure(event, options, "required field backgroundColor")
      return
    }

    if (options.frontColor === "#ffffff") {
      ;(options as any)._frontColor = "white"
    } else if (options.frontColor === "#000000") {
      ;(options as any)._frontColor = "black"
    }

    options.animation = extend(
      {
        duration: 0,
        timingFunc: "linear"
      },
      options.animation
    )

    invoke(event, options, result => {
      invokeCallback(event, options, result)
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

type SetNavigationBarTitleCompleteCallback = (res: GeneralCallbackResult) => void

export function setNavigationBarTitle<
  T extends SetNavigationBarTitleOptions = SetNavigationBarTitleOptions
>(options: T): AsyncReturn<T, SetNavigationBarTitleOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SET_NAVIGATION_BAR_TITLE
    invoke<SuccessResult<T>>(event, { title: options.title ?? "" }, result => {
      invokeCallback(event, options, result)
    })
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

export function hideHomeButton<T extends HideHomeButtonOptions = HideHomeButtonOptions>(
  options: T
): AsyncReturn<T, HideHomeButtonOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.HIDE_HOMM_BUTTON
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
