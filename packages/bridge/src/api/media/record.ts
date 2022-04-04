import { GeneralCallbackResult } from "../../async"
import { invoke, subscribe } from "../../bridge"

interface RecorderManagerStartOptions {
  duration?: number
  sampleRate?:
    | 8000
    | 11025
    | 12000
    | 16000
    | 22050
    | 24000
    | 32000
    | 44100
    | 48000
  numberOfChannels?: 1 | 2
  encodeBitRate?: number
  format?: "aac" | "wav"
}

interface RecorderManagerStopCallbackResult {
  tempFilePath: string
  duration: number
  fileSize: number
}

const PREFIX = "MODULE_AUDIO_RECORDER_"

const enum Events {
  ON_START = "ON_START",
  ON_STOP = "ON_STOP",
  ON_PAUSE = "ON_PAUSE",
  ON_RESUME = "ON_RESUME",
  ON_INTERRUPTION_BEGIN = "ON_INTERRUPTION_BEGIN",
  ON_INTERRUPTION_END = "ON_INTERRUPTION_END",
  ON_ERROR = "ON_ERROR"
}

const eventName = (event: Events) => PREFIX + event

const enum Methods {
  START = "start",
  STOP = "stop",
  PAUSE = "pause",
  RESUME = "resume"
}

class RecorderManager {
  onStartCallback?: () => void

  onStopCallback?: (res: RecorderManagerStopCallbackResult) => void

  onPauseCallback?: () => void

  onResumeCallback?: () => void

  onInterruptionBeginCallback?: () => void

  onInterruptionEndCallback?: () => void

  onErrorCallback?: (res: GeneralCallbackResult) => void

  constructor() {
    subscribe(eventName(Events.ON_START), _ => {
      this.onStartCallback && this.onStartCallback()
    })

    subscribe<RecorderManagerStopCallbackResult>(
      eventName(Events.ON_STOP),
      data => {
        this.onStopCallback && this.onStopCallback(data)
      }
    )

    subscribe(eventName(Events.ON_PAUSE), _ => {
      this.onPauseCallback && this.onPauseCallback()
    })

    subscribe(eventName(Events.ON_RESUME), _ => {
      this.onResumeCallback && this.onResumeCallback()
    })

    subscribe(eventName(Events.ON_INTERRUPTION_BEGIN), _ => {
      this.onInterruptionBeginCallback && this.onInterruptionBeginCallback()
    })

    subscribe(eventName(Events.ON_INTERRUPTION_END), _ => {
      this.onInterruptionEndCallback && this.onInterruptionEndCallback()
    })

    subscribe<{ error: string }>(eventName(Events.ON_ERROR), data => {
      this.onErrorCallback && this.onErrorCallback({ errMsg: data.error })
    })
  }

  start(options: RecorderManagerStartOptions) {
    const opt = {
      duration: 60000,
      sampleRate: 8000,
      numberOfChannels: 2,
      encodeBitRate: 48000,
      format: "aac"
    }

    this.operate(Methods.START, Object.assign(opt, options))
  }

  stop() {
    this.operate(Methods.STOP)
  }

  pause() {
    this.operate(Methods.PAUSE)
  }

  resume() {
    this.operate(Methods.RESUME)
  }

  onStart(callback: () => void) {
    this.onStartCallback = callback
  }

  onStop(callback: (res: RecorderManagerStopCallbackResult) => void) {
    this.onStopCallback = callback
  }

  onPause(callback: () => void) {
    this.onPauseCallback = callback
  }

  onResume(callback: () => void) {
    this.onResumeCallback = callback
  }

  onInterruptionBegin(callback: () => void) {
    this.onInterruptionBeginCallback = callback
  }

  onInterruptionEnd(callback: () => void) {
    this.onInterruptionEndCallback = callback
  }

  onError(callback: (res: GeneralCallbackResult) => void) {
    this.onErrorCallback = callback
  }

  operate(method: Methods, startData?: RecorderManagerStartOptions) {
    invoke("operateAudioRecorder", { method, startData })
  }
}

let globalRecorderManager: RecorderManager | undefined

export function getRecorderManager() {
  return globalRecorderManager || new RecorderManager()
}
