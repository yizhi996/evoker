import { onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"

enum SubscribeKeys {
  SET_VALUE = "WEBVIEW_KEYBOARD_SET_VALUE",
  ON_SHOW = "WEBVIEW_KEYBOARD_ON_SHOW",
  ON_HIDE = "WEBVIEW_KEYBOARD_ON_HIDE",
  ON_CONFIRM = "WEBVIEW_KEYBOARD_ON_CONFIRM",
  HEIGHT_CHANGE = "KEYBOARD_HEIGHT_CHANGE"
}

Object.values(SubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, data => {
    dispatchEvent(key, data)
  })
})

export function useKeyboard(inputId: number) {
  const ids = new Map<string, number>()

  function createListener(key: SubscribeKeys, callback: (data: any) => void) {
    const id = addEvent<{ inputId: number }>(key, data => {
      if (data.inputId === inputId) {
        callback(data)
      }
    })
    ids.set(key, id)
    return id
  }

  function removaAllListener() {
    ids.forEach((id, event) => removeEvent(event, id))
  }

  onUnmounted(() => {
    removaAllListener()
  })

  return {
    onKeyboardSetValue: (callback: (data: { value: string }) => void) => {
      return createListener(SubscribeKeys.SET_VALUE, callback)
    },
    onKeyboardShow: (callback: () => void) => {
      return createListener(SubscribeKeys.ON_SHOW, callback)
    },
    onKeyboardHide: (callback: () => void) => {
      return createListener(SubscribeKeys.ON_HIDE, callback)
    },
    onKeyboardConfirm: (callback: () => void) => {
      return createListener(SubscribeKeys.ON_CONFIRM, callback)
    },
    onKeyboardHeightChange: (callback: (data: { height: number; duration: number }) => void) => {
      return createListener(SubscribeKeys.HEIGHT_CHANGE, callback)
    },
    removaAllListener
  }
}
