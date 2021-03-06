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
  return wrapperAsyncAPI(options => {
    const event = Events.HIDE_TOASE
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
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
      cancelText: "??????",
      cancelColor: "#000000",
      confirmText: "??????",
      confirmColor: "#576B95",
      editable: false
    }
  )
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
  return wrapperAsyncAPI(options => {
    invoke<SuccessResult<T>>(Events.HIDE_TOASE, options, result => {
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

type ShowActionSheetSuccessCallback = (res: ShowActionSheetSuccessCallbackResult) => void

type ShowActionSheetFailCallback = (res: GeneralCallbackResult) => void

type ShowActionSheetCompleteCallback = (res: GeneralCallbackResult) => void

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
