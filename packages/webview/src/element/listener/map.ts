import { onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { dispatch, on, off } from "@nzoth/shared"

enum SubscribeKeys {}

Object.values(SubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, message => {
    dispatch(key, message)
  })
})

export default function useMap(mapId: number) {
  const ids = new Map<string, number>()

  function createListener(key: SubscribeKeys, callback: (data: any) => void) {
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
