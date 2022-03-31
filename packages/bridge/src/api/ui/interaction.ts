import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

const enum Events {
  SHOW_TOAST = "showToast",
  HIDE_TOASE = "hideToast",
  SHOW_MODAL = "showModal",
  SHOW_LOADING = "showLoading",
  HIDE_LOADING = "hideLoading",
  SHOW_ACTION_SHEET = "showActionSheet"
}

interface ShowToastOptions {
  title: string
  icon?: "success" | "error" | "loading" | "none"
  image?: string
  duration?: number
  mask?: boolean
  success?: ShowToastSuccessCallback
  fail?: ShowToastFailCallback
  complete?: ShowToastCompleteCallback
}

type ShowToastSuccessCallback = (res: GeneralCallbackResult) => void

type ShowToastFailCallback = (res: GeneralCallbackResult) => void

type ShowToastCompleteCallback = (res: GeneralCallbackResult) => void

export function showToast<T extends ShowToastOptions = ShowToastOptions>(
  options: T
): AsyncReturn<T, ShowToastOptions> {
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = Object.assign(
      {
        title: "",
        icon: "success",
        duration: 1500,
        mask: false
      },
      options
    )
    invoke<SuccessResult<T>>(Events.SHOW_TOAST, finalOptions, result => {
      invokeCallback(Events.SHOW_TOAST, finalOptions, result)
    })
  }, options)
}

interface HideToastOptions {
  success?: HideToastSuccessCallback
  fail?: HideToastFailCallback
  complete?: HideToastCompleteCallback
}

type HideToastSuccessCallback = (res: GeneralCallbackResult) => void

type HideToastFailCallback = (res: GeneralCallbackResult) => void

type HideToastCompleteCallback = (res: GeneralCallbackResult) => void

export function hideToast<T extends HideToastOptions = HideToastOptions>(
  options: T
): AsyncReturn<T, HideToastOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.HIDE_TOASE, {}, result => {
      invokeCallback(Events.HIDE_TOASE, options, result)
    })
  }, options)
}

interface ShowModalOptions {
  title?: string
  content?: string
  showCancel?: boolean
  cancelText?: string
  cancelColor?: string
  confirmText?: string
  confirmColor?: string
  editable?: boolean
  placeholderText?: string
  success?: ShowModalSuccessCallback
  fail?: ShowModalFailCallback
  complete?: ShowModalCompleteCallback
}

interface ShowModalSuccessCallbackResult {
  content?: string
  confirm: boolean
  cancel: boolean
}

type ShowModalSuccessCallback = (res: ShowModalSuccessCallbackResult) => void

type ShowModalFailCallback = (res: GeneralCallbackResult) => void

type ShowModalCompleteCallback = (res: GeneralCallbackResult) => void

export function showModal<T extends ShowModalOptions = ShowModalOptions>(
  options: T
): AsyncReturn<T, ShowModalOptions> {
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = Object.assign(
      {
        showCancel: true,
        cancelText: "取消",
        cancelColor: "#000000",
        confirmText: "确定",
        confirmColor: "#576B95",
        editable: false
      },
      options
    )
    invoke<SuccessResult<T>>(Events.SHOW_MODAL, finalOptions, result => {
      invokeCallback(Events.SHOW_MODAL, finalOptions, result)
    })
  }, options)
}

interface ShowLoadingOptions {
  title: string
  mask?: boolean
  success?: ShowLoadingSuccessCallback
  fail?: ShowLoadingFailCallback
  complete?: ShowLoadingCompleteCallback
}

type ShowLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type ShowLoadingFailCallback = (res: GeneralCallbackResult) => void

type ShowLoadingCompleteCallback = (res: GeneralCallbackResult) => void

export function showLoading<T extends ShowLoadingOptions = ShowLoadingOptions>(
  options: T
): AsyncReturn<T, ShowLoadingOptions> {
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = Object.assign(
      {
        title: "",
        icon: "loading",
        duration: -1,
        mask: false
      },
      options
    )
    invoke<SuccessResult<T>>(Events.SHOW_TOAST, finalOptions, result => {
      invokeCallback(Events.SHOW_LOADING, finalOptions, result)
    })
  }, options)
}

interface HideLoadingOptions {
  success?: HideLoadingSuccessCallback
  fail?: HideLoadingFailCallback
  complete?: HideLoadingCompleteCallback
}

type HideLoadingSuccessCallback = (res: GeneralCallbackResult) => void

type HideLoadingFailCallback = (res: GeneralCallbackResult) => void

type HideLoadingCompleteCallback = (res: GeneralCallbackResult) => void

export function hideLoading<T extends HideLoadingOptions = HideLoadingOptions>(
  options: T
): AsyncReturn<T, HideLoadingOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.HIDE_TOASE, {}, result => {
      invokeCallback(Events.HIDE_LOADING, options, result)
    })
  }, options)
}

interface ShowActionSheetOptions {
  alertText?: string
  itemList: string[]
  itemColor?: string
  success?: ShowActionSheetSuccessCallback
  fail?: ShowActionSheetFailCallback
  complete?: ShowActionSheetCompleteCallback
}

interface ShowActionSheetSuccessCallbackResult {
  tapIndex: number
}

type ShowActionSheetSuccessCallback = (
  res: ShowActionSheetSuccessCallbackResult
) => void

type ShowActionSheetFailCallback = (res: GeneralCallbackResult) => void

type ShowActionSheetCompleteCallback = (res: GeneralCallbackResult) => void

export function showActionSheet<
  T extends ShowActionSheetOptions = ShowActionSheetOptions
>(options: T): AsyncReturn<T, ShowActionSheetOptions> {
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = Object.assign(
      {
        itemList: []
      },
      options
    )
    invoke<SuccessResult<T>>(Events.SHOW_ACTION_SHEET, finalOptions, result => {
      invokeCallback(Events.SHOW_ACTION_SHEET, finalOptions, result)
    })
  }, options)
}
