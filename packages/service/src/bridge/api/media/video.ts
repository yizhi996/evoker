import { invokeWebViewMethod } from "../../fromWebView"
import { ContextInfo } from "../html/selector"

const enum Methods {
  PLAY = "play",
  PAUSE = "pause",
  STOP = "stop",
  SEEK = "seek",
  SET_PLAYBACK_RATE = "setPlaybackRate",
  REQUEST_FULL_SCREEN = "requestFullScreen",
  EXIT_FULL_SCREEN = "exitFullScreen"
}

export class VideoContext {
  context: ContextInfo

  constructor(context: ContextInfo) {
    this.context = context
  }

  private operateVideoPlayer = (method: Methods, data: Record<string, any> = {}) => {
    invokeWebViewMethod(
      "operateContext",
      { nodeId: this.context.nodeId, method, data },
      undefined,
      this.context.webViewId
    )
  }

  play() {
    this.operateVideoPlayer(Methods.PLAY)
  }

  pause() {
    this.operateVideoPlayer(Methods.PAUSE)
  }

  stop() {
    this.operateVideoPlayer(Methods.STOP)
  }

  seek(position: number) {
    this.operateVideoPlayer(Methods.SEEK, { position })
  }

  playbackRate(rate: number) {
    this.operateVideoPlayer(Methods.SET_PLAYBACK_RATE, { rate })
  }

  requestFullScreen(options: { direction?: 0 | 90 | -90 } = {}) {
    if (![0, 90, -90].includes(options.direction as number)) {
      options.direction = undefined
    }
    this.operateVideoPlayer(Methods.REQUEST_FULL_SCREEN, options)
  }

  exitFullScreen() {
    this.operateVideoPlayer(Methods.EXIT_FULL_SCREEN)
  }
}

export function createVideoContextInstance(context: ContextInfo) {
  return new VideoContext(context)
}
