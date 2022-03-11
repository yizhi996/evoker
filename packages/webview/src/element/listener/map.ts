import { onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { dispatch, on, off } from "@nzoth/shared"

enum MapSubscribeKeys {
  WEBVIEW_TEXTAREA_HEIGHT_CHANGE = "WEBVIEW_MAP"
}

Object.values(MapSubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, message => {
    dispatch(key, message)
  })
})

export default function useMap(mapId: number) {
  const ids = new Map<string, number>()

  function createListener(
    key: MapSubscribeKeys,
    callback: (data: any) => void
  ) {
    const id = on(key, data => {
      if (data.mapId === mapId) {
        callback(data)
      }
    })
    ids.set(key, id)
    return id
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
    removaAllListener
  }
}
