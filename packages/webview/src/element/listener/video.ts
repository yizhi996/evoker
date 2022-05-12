import { NZJSBridge } from "../../bridge"
import { addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"

enum SubscribeKeys {
  ON_LOADED_DATA = "ON_LOADED_DATA",
  ON_PLAY = "ON_PLAY",
  ON_PAUSE = "ON_PAUSE",
  ON_ENDED = "ON_ENDED",
  ON_ERROR = "ON_ERROR",
  TIME_UPDATE = "TIME_UPDATE",
  BUFFER_UPDATE = "BUFFER_UPDATE",
  FULLSCREEN_CHANGE = "FULLSCREEN_CHANGE",
  SEEK_COMPLETE = "SEEK_COMPLETE",
  WAITING = "WAITING"
}

const combineSubscribeKey = (key: SubscribeKeys) => {
  return "MODULE_VIDEO_" + key
}

Object.values(SubscribeKeys).forEach(key => {
  const _key = combineSubscribeKey(key)
  NZJSBridge.subscribe(_key, data => {
    dispatchEvent(_key, data)
  })
})

interface VideoData {
  duration: number
  width: number
  height: number
}

export default function useVideoPlayer(videoPlayerId: number) {
  const ids = new Map<string, number>()

  function createListener(key: SubscribeKeys, callback: (data: any) => void) {
    const _key = combineSubscribeKey(key)
    const id = addEvent<{ videoPlayerId: number }>(_key, data => {
      if (data.videoPlayerId === videoPlayerId) {
        callback(data)
      }
    })
    ids.set(_key, id)
    return id
  }

  return {
    onLoadedData: (callback: (data: VideoData) => void) => {
      return createListener(SubscribeKeys.ON_LOADED_DATA, callback)
    },
    onPlay: (callback: () => void) => {
      return createListener(SubscribeKeys.ON_PLAY, callback)
    },
    onPause: (callback: () => void) => {
      return createListener(SubscribeKeys.ON_PAUSE, callback)
    },
    onEnded: (callback: () => void) => {
      return createListener(SubscribeKeys.ON_ENDED, callback)
    },
    onError: (callback: (data: { error: string }) => void) => {
      return createListener(SubscribeKeys.ON_ERROR, callback)
    },
    timeUpdate: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.TIME_UPDATE, callback)
    },
    fullscreenChange: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.FULLSCREEN_CHANGE, callback)
    },
    bufferUpdate: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.BUFFER_UPDATE, callback)
    },
    seekComplete: (callback: (data: { position: number }) => void) => {
      return createListener(SubscribeKeys.SEEK_COMPLETE, callback)
    },
    waiting: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.WAITING, callback)
    },
    removaAllListener: () => {
      ids.forEach((id, event) => removeEvent(event, id))
    }
  }
}
