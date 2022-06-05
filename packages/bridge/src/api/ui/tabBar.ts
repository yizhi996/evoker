import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import { ErrorCodes, errorMessage } from "../../errors"

const enum Events {
  SET_TAB_BAR_BADGE = "setTabBarBadge",
  REMOVE_TAB_BAR_BADGE = "removeTabBarBadge",
  SHOW_TAB_BAR_RED_DOT = "showTabBarRedDot",
  HIDE_TAB_BAR_RED_DOT = "hideTabBarRedDot",
  SET_TAB_BAR_ITEM = "setTabBarItem",
  SET_TAB_BAR_STYLE = "setTabBarStyle"
}

interface SetTabBarBadgeOptions {
  index: number
  text: string
  success?: SetTabBarBadgeSuccessCallback
  fail?: SetTabBarBadgeFailCallback
  complete?: SetTabBarBadgeCompleteCallback
}

type SetTabBarBadgeSuccessCallback = (res: GeneralCallbackResult) => void

type SetTabBarBadgeFailCallback = (res: GeneralCallbackResult) => void

type SetTabBarBadgeCompleteCallback = (res: GeneralCallbackResult) => void

export function setTabBarBadge<T extends SetTabBarBadgeOptions = SetTabBarBadgeOptions>(
  options: T
): AsyncReturn<T, SetTabBarBadgeOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET_TAB_BAR_BADGE
    if (options.index == null) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "index"))
      return
    }
    if (!options.text) {
      invokeFailure(event, options, errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "text"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface RemoveTabBarBadgeOptions {
  index: number
  success?: RemoveTabBarBadgeSuccessCallback
  fail?: RemoveTabBarBadgeFailCallback
  complete?: RemoveTabBarBadgeCompleteCallback
}

type RemoveTabBarBadgeSuccessCallback = (res: GeneralCallbackResult) => void

type RemoveTabBarBadgeFailCallback = (res: GeneralCallbackResult) => void

type RemoveTabBarBadgeCompleteCallback = (res: GeneralCallbackResult) => void

export function removeTabBarBadge<T extends RemoveTabBarBadgeOptions = RemoveTabBarBadgeOptions>(
  options: T
): AsyncReturn<T, RemoveTabBarBadgeOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.REMOVE_TAB_BAR_BADGE
    if (options.index == null) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "index"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface ShowTabBarRedDotOptions {
  index: number
  success?: ShowTabBarRedDotSuccessCallback
  fail?: ShowTabBarRedDotFailCallback
  complete?: ShowTabBarRedDotCompleteCallback
}

type ShowTabBarRedDotSuccessCallback = (res: GeneralCallbackResult) => void

type ShowTabBarRedDotFailCallback = (res: GeneralCallbackResult) => void

type ShowTabBarRedDotCompleteCallback = (res: GeneralCallbackResult) => void

export function showTabBarRedDot<T extends ShowTabBarRedDotOptions = ShowTabBarRedDotOptions>(
  options: T
): AsyncReturn<T, ShowTabBarRedDotOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SHOW_TAB_BAR_RED_DOT
    if (options.index == null) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "index"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface HideTabBarRedDotOptions {
  index: number
  success?: HideTabBarRedDotSuccessCallback
  fail?: HideTabBarRedDotFailCallback
  complete?: HideTabBarRedDotCompleteCallback
}

type HideTabBarRedDotSuccessCallback = (res: GeneralCallbackResult) => void

type HideTabBarRedDotFailCallback = (res: GeneralCallbackResult) => void

type HideTabBarRedDotCompleteCallback = (res: GeneralCallbackResult) => void

export function hideTabBarRedDot<T extends HideTabBarRedDotOptions = HideTabBarRedDotOptions>(
  options: T
): AsyncReturn<T, HideTabBarRedDotOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.HIDE_TAB_BAR_RED_DOT
    if (options.index == null) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "index"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface SetTabBarItemOptions {
  index: number
  text?: string
  iconPath?: string
  selectedIconPath?: string
  success?: SetTabBarItemSuccessCallback
  fail?: SetTabBarItemFailCallback
  complete?: SetTabBarItemCompleteCallback
}

type SetTabBarItemSuccessCallback = (res: GeneralCallbackResult) => void

type SetTabBarItemFailCallback = (res: GeneralCallbackResult) => void

type SetTabBarItemCompleteCallback = (res: GeneralCallbackResult) => void

export function setTabBarItem<T extends SetTabBarItemOptions = SetTabBarItemOptions>(
  options: T
): AsyncReturn<T, SetTabBarItemOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET_TAB_BAR_ITEM
    if (options.index == null) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "index"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface SetTabBarStyleOptions {
  color?: string
  selectedColor?: string
  backgroundColor?: string
  borderStyle?: "black" | "white"
  success?: SetTabBarStyleSuccessCallback
  fail?: SetTabBarStyleFailCallback
  complete?: SetTabBarStyleCompleteCallback
}

type SetTabBarStyleSuccessCallback = (res: GeneralCallbackResult) => void

type SetTabBarStyleFailCallback = (res: GeneralCallbackResult) => void

type SetTabBarStyleCompleteCallback = (res: GeneralCallbackResult) => void

export function setTabBarStyle<T extends SetTabBarStyleOptions = SetTabBarStyleOptions>(
  options: T
): AsyncReturn<T, SetTabBarStyleOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET_TAB_BAR_STYLE
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
