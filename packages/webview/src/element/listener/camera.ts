import { onUnmounted } from "vue"
import { NZJSBridge, authorize } from "../../bridge"
import { AuthorizationStatus } from "@nzoth/bridge"
import { addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"

enum SubscribeKeys {
  ON_INIT_DONE = "MODULE_CAMERA_ON_INIT_DONE",
  ON_ERROR = "MODULE_CAMERA_ON_ERROR",
  ON_SCAN_CODE = "MODULE_CAMERA_ON_SCAN_CODE"
}

Object.values(SubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, data => {
    dispatchEvent(key, data)
  })
})

let cameraAuthorizedStatus = AuthorizationStatus.notDetermined

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
    return createListener(SubscribeKeys.ON_INIT_DONE, callback)
  }

  function onScanCode(callback: (data: { value: string }) => void) {
    return createListener(SubscribeKeys.ON_SCAN_CODE, callback)
  }

  function onError(callback: (data: { error: string }) => void) {
    return createListener(SubscribeKeys.ON_ERROR, callback)
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
    onError,
    removaAllListener,
    authorize: async () => {
      if (cameraAuthorizedStatus !== AuthorizationStatus.notDetermined) {
        return cameraAuthorizedStatus
      }
      try {
        await authorize({ scope: "scope.camera" })
        cameraAuthorizedStatus = AuthorizationStatus.authorized
      } catch {
        cameraAuthorizedStatus = AuthorizationStatus.denied
      }
      return cameraAuthorizedStatus
    }
  }
}
