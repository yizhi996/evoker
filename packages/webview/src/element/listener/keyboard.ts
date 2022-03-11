import { onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { dispatch, on, off } from "@nzoth/shared"

enum KeyboardSubscribeKeys {
  WEBVIEW_KEYBOARD_SET_VALUE = "WEBVIEW_KEYBOARD_SET_VALUE",
  WEBVIEW_KEYBOARD_ON_SHOW = "WEBVIEW_KEYBOARD_ON_SHOW",
  WEBVIEW_KEYBOARD_ON_HIDE = "WEBVIEW_KEYBOARD_ON_HIDE",
  WEBVIEW_KEYBOARD_ON_CONFIRM = "WEBVIEW_KEYBOARD_ON_CONFIRM",
  WEBVIEW_KEYBOARD_HEIGHT_CHANGE = "WEBVIEW_KEYBOARD_HEIGHT_CHANGE"
}

Object.values(KeyboardSubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, message => {
    dispatch(key, message)
  })
})

export default function useKeyboard(inputId: number) {
  const ids = new Map<string, number>()

  function createListener(
    key: KeyboardSubscribeKeys,
    callback: (data: any) => void
  ) {
    const id = on(key, data => {
      if (data.inputId === inputId) {
        callback(data)
      }
    })
    ids.set(key, id)
    return id
  }

  function onKeyboardSetValue(callback: (data: any) => void) {
    return createListener(
      KeyboardSubscribeKeys.WEBVIEW_KEYBOARD_SET_VALUE,
      callback
    )
  }

  function onKeyboardShow(callback: () => void) {
    return createListener(
      KeyboardSubscribeKeys.WEBVIEW_KEYBOARD_ON_SHOW,
      callback
    )
  }

  function onKeyboardHide(callback: (data: any) => void) {
    return createListener(
      KeyboardSubscribeKeys.WEBVIEW_KEYBOARD_ON_HIDE,
      callback
    )
  }

  function onKeyboardConfirm(callback: (data: any) => void) {
    return createListener(
      KeyboardSubscribeKeys.WEBVIEW_KEYBOARD_ON_CONFIRM,
      callback
    )
  }

  function onKeyboardHeightChange(callback: (data: any) => void) {
    return createListener(
      KeyboardSubscribeKeys.WEBVIEW_KEYBOARD_HEIGHT_CHANGE,
      callback
    )
  }

  function removaAllListener() {
    ids.forEach((value, key) => {
      off(key, value)
    })
  }

  onUnmounted(() => {
    removaAllListener()
  })

  return {
    onKeyboardSetValue,
    onKeyboardShow,
    onKeyboardHide,
    onKeyboardConfirm,
    onKeyboardHeightChange,
    removaAllListener
  }
}
