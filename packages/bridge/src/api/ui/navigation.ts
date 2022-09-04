import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import { extend, isString } from "@vue/shared"
import { ERR_CANNOT_EMPTY, ERR_INVALID_ARG_TYPE, ERR_INVALID_ARG_VALUE } from "../../errors"

const enum Events {
  SET_NAVIGATION_BAR_TITLE = "setNavigationBarTitle",
  SHOW_NAVIGATION_BAR_LOADING = "showNavigationBarLoading",
  HIDE_NAVIGATION_BAR_LOADING = "hideNavigationBarLoading",
  SET_NAVIGATION_BAR_COLOR = "setNavigationBarColor",
  HIDE_HOMM_BUTTON = "hideHomeButton"
}

interface ShowNavigationBarLoadingOptions {
  /** 接口调用成功的回调函数 */
  success?: ShowNavigationBarLoadingSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowNavigationBarLoadingFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowNavigationBarLoadingCompleteCallback
}

type ShowNavigationBarLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type ShowNavigationBarLoadingFailCallback = (res: GeneralCallbackResult) => void

type ShowNavigationBarLoadingCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示当前页面导航栏加载动画 */
export function showNavigationBarLoading<
  T extends ShowNavigationBarLoadingOptions = ShowNavigationBarLoadingOptions
>(options: T): AsyncReturn<T, ShowNavigationBarLoadingOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SHOW_NAVIGATION_BAR_LOADING
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface HideNavigationBarLoadingOptions {
  /** 接口调用成功的回调函数 */
  success?: HideNavigationBarLoadingSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideNavigationBarLoadingFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideNavigationBarLoadingCompleteCallback
}

type HideNavigationBarLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type HideNavigationBarLoadingFailCallback = (res: GeneralCallbackResult) => void

type HideNavigationBarLoadingCompleteCallback = (res: GeneralCallbackResult) => void

/** 隐藏当前页面导航栏加载动画 */
export function hideNavigationBarLoading<
  T extends HideNavigationBarLoadingOptions = HideNavigationBarLoadingOptions
>(options: T): AsyncReturn<T, HideNavigationBarLoadingOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.HIDE_NAVIGATION_BAR_LOADING
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface SetNavigationBarColorOptions {
  /** 前景颜色值，包括按钮、标题、状态栏的颜色，仅支持 #ffffff 和 #000000 */
  frontColor: "#ffffff" | "#000000"
  /** 背景颜色，必须是 16 进制格式 */
  backgroundColor: string
  /** 动画效果 */
  animation?: SetNavigationBarColorAnimation
  /** 接口调用成功的回调函数 */
  success?: SetNavigationBarColorSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetNavigationBarColorFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetNavigationBarColorCompleteCallback
}

interface SetNavigationBarColorAnimation {
  /** 动画变化时间，单位 ms */
  duration?: number
  /** 动画类型
   *
   * 可选值：
   * - linear: 线性
   * - easeIn: 缓入
   * - easeOut: 缓出
   * - easeInOut: 缓入缓出
   */
  timingFunc?: "linear" | "easeIn" | "easeOut" | "easeInOut"
}

type SetNavigationBarColorSuccessCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarColorFailCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarColorCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置当前页面导航栏的颜色 */
export function setNavigationBarColor<
  T extends SetNavigationBarColorOptions = SetNavigationBarColorOptions
>(options: T): AsyncReturn<T, SetNavigationBarColorOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SET_NAVIGATION_BAR_COLOR
    const validTypes = ["#ffffff", "#000000"]
    if (!validTypes.includes(options.frontColor)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.frontColor", validTypes, options.frontColor)
      )
      return
    }

    if (!isString(options.backgroundColor)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.backgroundColor", "string", options.backgroundColor)
      )
      return
    }

    if (!options.backgroundColor) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.backgroundColor", options.backgroundColor, ERR_CANNOT_EMPTY)
      )
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
  /** 页面标题 */
  title: string
  /** 接口调用成功的回调函数 */
  success?: SetNavigationBarTitleSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SetNavigationBarTitleFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SetNavigationBarTitleCompleteCallback
}

type SetNavigationBarTitleSuccessCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarTitleFailCallback = (res: GeneralCallbackResult) => void

type SetNavigationBarTitleCompleteCallback = (res: GeneralCallbackResult) => void

/** 设置当前页面的标题 */
export function setNavigationBarTitle<
  T extends SetNavigationBarTitleOptions = SetNavigationBarTitleOptions
>(options: T): AsyncReturn<T, SetNavigationBarTitleOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.SET_NAVIGATION_BAR_TITLE
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { title: "" }
  )
}

interface HideHomeButtonOptions {
  /** 接口调用成功的回调函数 */
  success?: HideHomeButtonSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideHomeButtonFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideHomeButtonCompleteCallback
}

type HideHomeButtonSuccessCallback = (res: GeneralCallbackResult) => void

type HideHomeButtonFailCallback = (res: GeneralCallbackResult) => void

type HideHomeButtonCompleteCallback = (res: GeneralCallbackResult) => void

export function hideHomeButton<T extends HideHomeButtonOptions = HideHomeButtonOptions>(
  options: T
): AsyncReturn<T, HideHomeButtonOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.HIDE_HOMM_BUTTON
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
