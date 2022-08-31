import { addEvent, removeEvent, dispatchEvent } from "@evoker/shared"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { invoke, subscribe } from "../../bridge"

const KEYBOARD_HEIGHT_CHANGE = "KEYBOARD_HEIGHT_CHANGE"

subscribe(KEYBOARD_HEIGHT_CHANGE, result => {
  dispatchEvent(KEYBOARD_HEIGHT_CHANGE, result)
})

interface OnKeyboardHeighChangeCallbackResult {
  /** 键盘高度 */
  height: number
}

type OnKeyboardHeighChangeCallback = (res: OnKeyboardHeighChangeCallbackResult) => void

/** 监听键盘高度变化 */
export function onKeyboardHeighChange(
  /** 键盘高度变化事件的回调函数 */
  callback: OnKeyboardHeighChangeCallback
) {
  addEvent(KEYBOARD_HEIGHT_CHANGE, callback)
}

/** 取消监听键盘高度变化 */
export function offKeyboardHeighChange(
  /** 键盘高度变化事件的回调函数 */
  callback: OnKeyboardHeighChangeCallback
) {
  removeEvent(KEYBOARD_HEIGHT_CHANGE, callback)
}

interface hideKeyboardOptions {
  /** 接口调用成功的回调函数 */
  success?: hideKeyboardSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: hideKeyboardFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: hideKeyboardCompleteCallback
}

type hideKeyboardSuccessCallback = (res: GeneralCallbackResult) => void

type hideKeyboardFailCallback = (res: GeneralCallbackResult) => void

type hideKeyboardCompleteCallback = (res: GeneralCallbackResult) => void

/** 在 input、textarea 等 focus 拉起键盘之后，手动调用此接口收起键盘 */
export function hideKeyboard<T extends hideKeyboardOptions = hideKeyboardOptions>(
  options: T
): AsyncReturn<T, hideKeyboardOptions> {
  return wrapperAsyncAPI(options => {
    const event = "hideKeyboard"
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
