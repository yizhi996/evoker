import { NZJSBridge } from "../../bridge"
import { addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"

enum SubscribeKeys {
  ON_LOADED_DATA = "WEBVIEW_VIDEO_PLAYER_ON_LOADED_DATA",
  ON_PLAY = "WEBVIEW_VIDEO_PLAYER_ON_PLAY",
  ON_PAUSE = "WEBVIEW_VIDEO_PLAYER_ON_PAUSE",
  ON_ENDED = "WEBVIEW_VIDEO_PLAYER_ON_ENDED",
  ON_ERROR = "WEBVIEW_VIDEO_PLAYER_ON_ERROR",
  TIME_UPDATE = "WEBVIEW_VIDEO_PLAYER_TIME_UPDATE",
  BUFFER_UPDATE = "WEBVIEW_VIDEO_PLAYER_BUFFER_UPDATE"
}

Object.values(SubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, data => {
    dispatchEvent(key, data)
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
    const id = addEvent<{ videoPlayerId: number }>(key, data => {
      if (data.videoPlayerId === videoPlayerId) {
        callback(data)
      }
    })
    ids.set(key, id)
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
    onError: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.ON_ERROR, callback)
    },
    timeUpdate: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.TIME_UPDATE, callback)
    },
    bufferUpdate: (callback: (data: any) => void) => {
      return createListener(SubscribeKeys.BUFFER_UPDATE, callback)
    },
    removaAllListener: () => {
      ids.forEach((id, event) => removeEvent(event, id))
    }
  }
}
