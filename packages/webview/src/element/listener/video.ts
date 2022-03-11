import { NZJSBridge } from "../../bridge"
import { dispatch, on, off } from "@nzoth/shared"

enum VideoPlayerSubscribeKeys {
  WEBVIEW_VIDEO_PLAYER_ON_PLAY = "WEBVIEW_VIDEO_PLAYER_ON_PLAY",
  WEBVIEW_VIDEO_PLAYER_ON_PAUSE = "WEBVIEW_VIDEO_PLAYER_ON_PAUSE",
  WEBVIEW_VIDEO_PLAYER_ON_ERROR = "WEBVIEW_VIDEO_PLAYER_ON_ERROR",
  WEBVIEW_VIDEO_PLAYER_TIME_UPDATE = "WEBVIEW_VIDEO_PLAYER_TIME_UPDATE",
  WEBVIEW_VIDEO_PLAYER_BUFFER_UPDATE = "WEBVIEW_VIDEO_PLAYER_BUFFER_UPDATE"
}

Object.values(VideoPlayerSubscribeKeys).forEach(key => {
  NZJSBridge.subscribe(key, message => {
    dispatch(key, message)
  })
})

export default function useVideoPlayer(videoPlayerId: number) {
  const ids = new Map<string, number>()

  function createListener(
    key: VideoPlayerSubscribeKeys,
    callback: (data: any) => void
  ) {
    const id = on(key, data => {
      if (data.videoPlayerId === videoPlayerId) {
        callback(data)
      }
    })
    ids.set(key, id)
    return id
  }

  function onPlaye(callback: () => void) {
    return createListener(
      VideoPlayerSubscribeKeys.WEBVIEW_VIDEO_PLAYER_ON_PLAY,
      callback
    )
  }

  function onPause(callback: () => void) {
    return createListener(
      VideoPlayerSubscribeKeys.WEBVIEW_VIDEO_PLAYER_ON_PAUSE,
      callback
    )
  }

  function onError(callback: (data: any) => void) {
    return createListener(
      VideoPlayerSubscribeKeys.WEBVIEW_VIDEO_PLAYER_ON_ERROR,
      callback
    )
  }

  function timeUpdate(callback: (data: any) => void) {
    return createListener(
      VideoPlayerSubscribeKeys.WEBVIEW_VIDEO_PLAYER_TIME_UPDATE,
      callback
    )
  }

  function bufferUpdate(callback: (data: any) => void) {
    return createListener(
      VideoPlayerSubscribeKeys.WEBVIEW_VIDEO_PLAYER_BUFFER_UPDATE,
      callback
    )
  }

  function removaAllListener() {
    ids.forEach((value, key) => {
      off(key, value)
    })
  }

  return {
    onPlaye,
    onPause,
    onError,
    timeUpdate,
    bufferUpdate,
    removaAllListener
  }
}
