import { onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"

enum SubscribeKeys {
  INIT_DONE = "MODULE_CAMERA_INIT_DONE",
  SCAN_CODE = "MODULE_CAMERA_SCAN_CODE"
}

Object.values(SubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, data => {
    dispatchEvent(key, data)
  })
})

export default function useCamera(cameraId: number) {
  const ids = new Map<string, number>()

  function createListener(key: SubscribeKeys, callback: (data: any) => void) {
    const id = addEvent<{ cameraId: number }>(key, data => {
      if (data.cameraId === cameraId) {
        callback(data)
      }
    })
    ids.set(key, id)
    return id
  }

  function onInit(callback: (data: { maxZoom: number }) => void) {
    return createListener(SubscribeKeys.INIT_DONE, callback)
  }

  function onScanCode(callback: (data: { value: string }) => void) {
    return createListener(SubscribeKeys.SCAN_CODE, callback)
  }

  function removaAllListener() {
    ids.forEach((id, event) => removeEvent(event, id))
  }

  onUnmounted(() => {
    removaAllListener()
  })

  return {
    onInit,
    onScanCode,
    removaAllListener
  }
}
