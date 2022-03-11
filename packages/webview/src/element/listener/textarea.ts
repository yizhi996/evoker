import { onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { dispatch, on, off } from "@nzoth/shared"

enum TextAreaSubscribeKeys {
  WEBVIEW_TEXTAREA_HEIGHT_CHANGE = "WEBVIEW_TEXTAREA_HEIGHT_CHANGE"
}

Object.values(TextAreaSubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, message => {
    dispatch(key, message)
  })
})

export default function useTextArea(inputId: number) {
  const ids = new Map<string, number>()

  function createListener(
    key: TextAreaSubscribeKeys,
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

  function onTextAreaHeightChange(
    callback: (data: {
      inputId: number
      height: number
      lineCount: number
    }) => void
  ) {
    return createListener(
      TextAreaSubscribeKeys.WEBVIEW_TEXTAREA_HEIGHT_CHANGE,
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
    onTextAreaHeightChange,
    removaAllListener
  }
}
