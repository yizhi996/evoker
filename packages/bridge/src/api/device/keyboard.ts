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
  height: number
}

type OnKeyboardHeighChangeCallback = (res: OnKeyboardHeighChangeCallbackResult) => void

export function onKeyboardHeighChange(callback: OnKeyboardHeighChangeCallback) {
  addEvent(KEYBOARD_HEIGHT_CHANGE, callback)
}

export function offKeyboardHeighChange(callback: () => void) {
  removeEvent(KEYBOARD_HEIGHT_CHANGE, callback)
}

interface hideKeyboardOptions {
  success?: hideKeyboardSuccessCallback
  fail?: hideKeyboardFailCallback
  complete?: hideKeyboardCompleteCallback
}

type hideKeyboardSuccessCallback = (res: GeneralCallbackResult) => void

type hideKeyboardFailCallback = (res: GeneralCallbackResult) => void

type hideKeyboardCompleteCallback = (res: GeneralCallbackResult) => void

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
