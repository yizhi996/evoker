import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { isString } from "@vue/shared"

const enum Events {
  SHOW_TOAST = "showToast",
  HIDE_TOASE = "hideToast",
  SHOW_MODAL = "showModal",
  SHOW_LOADING = "showLoading",
  HIDE_LOADING = "hideLoading",
  SHOW_ACTION_SHEET = "showActionSheet"
}

interface ShowToastOptions {
  /** 提示的内容 */
  title: string
  /** 图标
   *
   * 可选值：
   * - success: 显示成功图标
   * - error: 显示失败图标
   * - loading: 显示加载图标
   * - none: 不显示图标
   */
  icon?: "success" | "error" | "loading" | "none"
  /** 自定义图标的本地路径，image 的优先级高于 icon */
  image?: string
  /** 提示的持续时间 */
  duration?: number
  /** 是否显示半透明蒙层，防止触摸穿透 */
  mask?: boolean
  /** 接口调用成功的回调函数 */
  success?: ShowToastSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowToastFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowToastCompleteCallback
}

type ShowToastSuccessCallback = (res: GeneralCallbackResult) => void

type ShowToastFailCallback = (res: GeneralCallbackResult) => void

type ShowToastCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示消息提示框 */
export function showToast<T extends ShowToastOptions = ShowToastOptions>(
  options: T
): AsyncReturn<T, ShowToastOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.SHOW_TOAST
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    {
      title: "",
      icon: "success",
      duration: 1500,
      mask: false
    }
  )
}

interface HideToastOptions {
  /** 接口调用成功的回调函数 */
  success?: HideToastSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideToastFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideToastCompleteCallback
}

type HideToastSuccessCallback = (res: GeneralCallbackResult) => void

type HideToastFailCallback = (res: GeneralCallbackResult) => void

type HideToastCompleteCallback = (res: GeneralCallbackResult) => void

/** 隐藏消息提示框 */
export function hideToast<T extends HideToastOptions = HideToastOptions>(
  options: T
): AsyncReturn<T, HideToastOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.HIDE_TOASE
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface ShowModalOptions {
  /** 标题 */
  title?: string
  /** 内容 */
  content?: string
  /** 是否显示取消按钮 */
  showCancel?: boolean
  /** 取消按钮的文字 */
  cancelText?: string
  /** 取消按钮的文字颜色，必须是 16 进制格式 */
  cancelColor?: string
  /** 确认按钮的文字 */
  confirmText?: string
  /** 确认按钮的文字颜色，必须是 16 进制格式 */
  confirmColor?: string
  /** 是否显示输入框 */
  editable?: boolean
  /** 显示输入框时的提示文本 */
  placeholderText?: string
  /** 接口调用成功的回调函数 */
  success?: ShowModalSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowModalFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowModalCompleteCallback
}

interface ShowModalSuccessCallbackResult {
  /** editable 为 true 时，用户输入的文本 */
  content?: string
  /** 为 true 时，表示用户点击了确定按钮 */
  confirm: boolean
  /** 为 true 时，表示用户点击了取消 */
  cancel: boolean
}

type ShowModalSuccessCallback = (res: ShowModalSuccessCallbackResult) => void

type ShowModalFailCallback = (res: GeneralCallbackResult) => void

type ShowModalCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示模态对话框 */
export function showModal<T extends ShowModalOptions = ShowModalOptions>(
  options: T
): AsyncReturn<T, ShowModalOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.SHOW_MODAL
      if (options.title && !isString(options.title)) {
        options.title = options.title + ""
      }
      if (options.content && !isString(options.content)) {
        options.content = options.content + ""
      }
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    {
      showCancel: true,
      cancelText: "取消",
      cancelColor: "#000000",
      confirmText: "确定",
      confirmColor: "#576B95",
      editable: false
    }
  )
}

interface ShowLoadingOptions {
  /** 提示的内容 */
  title: string
  /** 是否显示半透明蒙层，防止触摸穿透 */
  mask?: boolean
  /** 接口调用成功的回调函数 */
  success?: ShowLoadingSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowLoadingFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowLoadingCompleteCallback
}

type ShowLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type ShowLoadingFailCallback = (res: GeneralCallbackResult) => void

type ShowLoadingCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示 loading 提示框，需主动调用 `ek.hideLoading` 才能关闭提示框 */
export function showLoading<T extends ShowLoadingOptions = ShowLoadingOptions>(
  options: T
): AsyncReturn<T, ShowLoadingOptions> {
  return wrapperAsyncAPI(
    options => {
      invoke<SuccessResult<T>>(Events.SHOW_TOAST, options, result => {
        invokeCallback(Events.SHOW_LOADING, options, result)
      })
    },
    options,
    { title: "", icon: "loading", duration: -1, mask: false }
  )
}

interface HideLoadingOptions {
  /** 接口调用成功的回调函数 */
  success?: HideLoadingSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: HideLoadingFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: HideLoadingCompleteCallback
}

type HideLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type HideLoadingFailCallback = (res: GeneralCallbackResult) => void

type HideLoadingCompleteCallback = (res: GeneralCallbackResult) => void

/** 隐藏 loading 提示框 */
export function hideLoading<T extends HideLoadingOptions = HideLoadingOptions>(
  options: T
): AsyncReturn<T, HideLoadingOptions> {
  return wrapperAsyncAPI(options => {
    invoke<SuccessResult<T>>(Events.HIDE_TOASE, options, result => {
      invokeCallback(Events.HIDE_LOADING, options, result)
    })
  }, options)
}

interface ShowActionSheetOptions {
  /** 警示文案 */
  alertText?: string
  /** 按钮的文字数组，数组长度最大为 6 */
  itemList: string[]
  /** 按钮的文字颜色，必须是 16 进制格式 */
  itemColor?: string
  /** 接口调用成功的回调函数 */
  success?: ShowActionSheetSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ShowActionSheetFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ShowActionSheetCompleteCallback
}

interface ShowActionSheetSuccessCallbackResult {
  /** 用户点击的按钮序号，从上到下的顺序，从0开始 */
  tapIndex: number
}

type ShowActionSheetSuccessCallback = (res: ShowActionSheetSuccessCallbackResult) => void

type ShowActionSheetFailCallback = (res: GeneralCallbackResult) => void

type ShowActionSheetCompleteCallback = (res: GeneralCallbackResult) => void

/** 显示操作菜单 */
export function showActionSheet<T extends ShowActionSheetOptions = ShowActionSheetOptions>(
  options: T
): AsyncReturn<T, ShowActionSheetOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.SHOW_ACTION_SHEET
      if (options.itemList.length > 6) {
        options.itemList = options.itemList.slice(0, 6)
      }
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    {
      itemList: [] as string[]
    }
  )
}
