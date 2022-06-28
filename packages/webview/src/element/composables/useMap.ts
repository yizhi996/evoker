import { onUnmounted } from "vue"
import { JSBridge } from "../../bridge"
import { addEvent, removeEvent, dispatchEvent } from "@evoker/shared"

enum SubscribeKeys {
  ON_UPDATED = "ON_UPDATED",
  ON_TAP = "ON_TAP",
  ON_TAP_POI = "ON_TAP_POI",
  ON_REGION_CHANGE = "ON_REGION_CHANGE"
}

const combineSubscribeKey = (key: SubscribeKeys) => {
  return "MODULE_MAP_" + key
}

Object.values(SubscribeKeys).forEach(key => {
  const _key = combineSubscribeKey(key)
  JSBridge.subscribe(_key, data => {
    dispatchEvent(_key, data)
  })
})

interface Coordinate {
  longitude: number
  latitude: number
}

export function useMap(mapId: number) {
  const ids = new Map<string, number>()

  function createListener(key: SubscribeKeys, callback: (data: any) => void) {
    const _key = combineSubscribeKey(key)
    const id = addEvent<{ mapId: number }>(_key, data => {
      data.mapId === mapId && callback(data)
    })
    ids.set(_key, id)
    return id
  }

  function removaAllListener() {
    ids.forEach((value, key) => {
      removeEvent(key, value)
    })
  }

  onUnmounted(() => {
    removaAllListener()
  })

  return {
    onUpdated: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.ON_UPDATED, callback)
    },
    onTap: (callback: (data: Coordinate) => void) => {
      return createListener(SubscribeKeys.ON_TAP, callback)
    },
    onTapPoi: (callback: (data: Coordinate & { name: string }) => void) => {
      return createListener(SubscribeKeys.ON_TAP_POI, callback)
    },
    onRegionChange: (
      callback: (data: { type: "begin" | "end"; centerLocation: Coordinate }) => void
    ) => {
      return createListener(SubscribeKeys.ON_REGION_CHANGE, callback)
    },
    removaAllListener
  }
}
