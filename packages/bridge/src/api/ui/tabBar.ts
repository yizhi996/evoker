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
  /** Tab Bar 的哪一项，从左边算起第一个为 0 */
  index: number
  /** 显示的文本 */
  text: string
  /** 接口调用成功的回调函数 */
  success?: SetTabBarBadgeSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetTabBarBadgeFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetTabBarBadgeCompleteCallback
}

type SetTabBarBadgeSuccessCallback = (res: GeneralCallbackResult) => void

type SetTabBarBadgeFailCallback = (res: GeneralCallbackResult) => void

type SetTabBarBadgeCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置 Tab Bar 的右上角文本 */
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
  /** Tab Bar 的哪一项，从左边算起第一个为 0 */
  index: number
  /** 接口调用成功的回调函数 */
  success?: RemoveTabBarBadgeSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: RemoveTabBarBadgeFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: RemoveTabBarBadgeCompleteCallback
}

type RemoveTabBarBadgeSuccessCallback = (res: GeneralCallbackResult) => void

type RemoveTabBarBadgeFailCallback = (res: GeneralCallbackResult) => void

type RemoveTabBarBadgeCompleteCallback = (res: GeneralCallbackResult) => void

/** 移除 Tab Bar 的右上角文本 */
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
  /** Tab Bar 的哪一项，从左边算起第一个为 0 */
  index: number
  /** 接口调用成功的回调函数 */
  success?: ShowTabBarRedDotSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowTabBarRedDotFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowTabBarRedDotCompleteCallback
}

type ShowTabBarRedDotSuccessCallback = (res: GeneralCallbackResult) => void

type ShowTabBarRedDotFailCallback = (res: GeneralCallbackResult) => void

type ShowTabBarRedDotCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示 Tab Bar 某一项的右上角的红点 */
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
  /** Tab Bar 的哪一项，从左边算起第一个为0 */
  index: number
  /** 接口调用成功的回调函数 */
  success?: HideTabBarRedDotSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideTabBarRedDotFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideTabBarRedDotCompleteCallback
}

type HideTabBarRedDotSuccessCallback = (res: GeneralCallbackResult) => void

type HideTabBarRedDotFailCallback = (res: GeneralCallbackResult) => void

type HideTabBarRedDotCompleteCallback = (res: GeneralCallbackResult) => void

/** 隐藏 Tab Bar 某一项的右上角的红点 */
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
  /** Tab Bar 的哪一项，从左边算起第一个为 0 */
  index: number
  /** Tab Bar 的文字 */
  text?: string
  /** Tab Bar 的图片路径，支持本地、临时和网络路径 */
  iconPath?: string
  /** Tab Bar 的选中时的图片路径，支持本地、临时和网络路径 */
  selectedIconPath?: string
  success?: SetTabBarItemSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetTabBarItemFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetTabBarItemCompleteCallback
}

type SetTabBarItemSuccessCallback = (res: GeneralCallbackResult) => void

type SetTabBarItemFailCallback = (res: GeneralCallbackResult) => void

type SetTabBarItemCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置 Tab Bar 某一项的内容 */
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
  /** Tab Bar 的文字颜色，必须是 16 进制格式 */
  color?: string
  /** Tab Bar 的文字选中时的颜色，必须是 16 进制格式 */
  selectedColor?: string
  /** Tab Bar 的背景颜色，必须是 16 进制格式 */
  backgroundColor?: string
  /** Tab Bar 的上边框线条颜色，只支持 white / black */
  borderStyle?: "black" | "white"
  /** 接口调用成功的回调函数 */
  success?: SetTabBarStyleSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetTabBarStyleFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetTabBarStyleCompleteCallback
}

type SetTabBarStyleSuccessCallback = (res: GeneralCallbackResult) => void

type SetTabBarStyleFailCallback = (res: GeneralCallbackResult) => void

type SetTabBarStyleCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置 Tab Bar 的整体样式 */
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
