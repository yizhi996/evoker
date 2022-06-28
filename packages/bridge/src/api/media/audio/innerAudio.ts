import { clamp, addEvent, removeEvent, dispatchEvent } from "@evoker/shared"
import { invoke, subscribe } from "../../../bridge"
import {
  wrapperAsyncAPI,
  invokeCallback,
  AsyncReturn,
  SuccessResult,
  GeneralCallbackResult
} from "../../../async"

interface InnerAudioContextErrorCallbackResult {
  errMsg: string
}

let audioId = 0

const enum Methods {
  PLAY = "play",
  PAUSE = "pause",
  STOP = "stop",
  REPLAY = "replay",
  SEEK = "seek",
  DESTROY = "destroy",
  SET_VOLUME = "setVolume",
  SET_SRC = "setSrc",
  SET_PLAYBACK_RATE = "setPlaybackRate"
}

const PREFIX = "MODULE_INNER_AUDIO_CONTEXT_"

enum Events {
  ON_CANPLAY = "ON_CANPLAY",
  ON_PLAY = "ON_PLAY",
  ON_STOP = "ON_STOP",
  ON_ENDED = "ON_ENDED",
  ON_PAUSE = "ON_PAUSE",
  ON_WAITING = "ON_WAITING",
  ON_ERROR = "ON_ERROR",
  ON_SEEKING = "ON_SEEKING",
  ON_SEEKED = "ON_SEEKED",
  ON_TIME_UPDATE = "ON_TIME_UPDATE",
  ON_BUFFER_UPDATE = "ON_BUFFER_UPDATE"
}

const getEventName = (event: Events) => PREFIX + event

class InnerAudioContext {
  private readonly id: number = audioId++

  public startTime: number = 0

  public autoplay: boolean = false

  public loop: boolean = false

  private _src: string = ""

  private _volume: number = 1

  private _playbackRate: number = 1

  private _duration: number = 0

  private _currentTime: number = 0

  private _paused: boolean = false

  private _buffered: number = 0

  private destroyed = false

  private removaAllListener

  constructor() {
    const {
      onCanplay,
      onPlay,
      onStop,
      onEnded,
      onPause,
      onWaiting,
      onError,
      onSeeked,
      onSeeking,
      onTimeUpdate,
      onBufferUpdate,
      removaAllListener
    } = useAudio(this.id)

    onCanplay(({ duration }) => {
      this._duration = duration
      dispatchEvent(this.innerEventName(Events.ON_CANPLAY))
      this.seek(this.startTime)
    })

    onPlay(() => {
      this._paused = false
      dispatchEvent(this.innerEventName(Events.ON_PLAY))
    })

    onPause(() => {
      this._paused = true
      dispatchEvent(this.innerEventName(Events.ON_PAUSE))
    })

    onStop(() => {
      this._paused = true
      dispatchEvent(this.innerEventName(Events.ON_STOP))
    })

    onEnded(() => {
      this._paused = true
      if (this.loop) {
        this.operate(Methods.REPLAY)
      }
      dispatchEvent(this.innerEventName(Events.ON_ENDED))
    })

    onWaiting(() => {
      dispatchEvent(this.innerEventName(Events.ON_WAITING))
    })

    onError(res => {
      this._paused = true
      dispatchEvent(this.innerEventName(Events.ON_ERROR), res)
    })

    onTimeUpdate(({ time }) => {
      this._currentTime = time
      dispatchEvent(this.innerEventName(Events.ON_TIME_UPDATE))
    })

    onBufferUpdate(({ bufferTime }) => {
      this._buffered = bufferTime
    })

    onSeeking(() => {
      dispatchEvent(this.innerEventName(Events.ON_SEEKING))
    })

    onSeeked(() => {
      dispatchEvent(this.innerEventName(Events.ON_SEEKED))
    })

    this.removaAllListener = removaAllListener
  }

  private innerEventName = (event: Events) => "_" + getEventName(event)

  get src() {
    return this._src
  }

  set src(newValue) {
    this._src = newValue
    this.operate(Methods.SET_SRC, { src: newValue })
    this.autoplay && this.play()
  }

  get volume() {
    return this._volume
  }

  set volume(newValue) {
    const value = clamp(newValue, 0.5, 2.0)
    this._volume = value
    this.src && this.operate(Methods.SET_VOLUME, { volume: value })
  }

  get playbackRate() {
    return this._playbackRate
  }

  set playbackRate(newValue) {
    this._playbackRate = newValue
    this.operate(Methods.SET_PLAYBACK_RATE, { rate: newValue })
  }

  get duration() {
    return this._duration
  }

  get currentTime() {
    return this._currentTime
  }

  get paused() {
    return this._paused
  }

  get buffered() {
    return this._buffered
  }

  private operate(method: Methods, data: Record<string, any> = {}) {
    !this.destroyed &&
      invoke("operateInnerAudioContext", {
        audioId: this.id,
        method,
        data
      })
  }

  play() {
    if (this.destroyed) {
      console.log("[Evoker] InnerAudioContext is destroyed")
      return
    }
    if (!this.src) {
      console.error("[Evoker] InnerAudioContext src cannot be empty")
      return
    }
    this.operate(Methods.PLAY, {
      audioId: this.id,
      src: this.src,
      volume: this.volume,
      playbackRate: this.playbackRate
    })
  }

  pause() {
    this.operate(Methods.PAUSE)
  }

  stop() {
    this.operate(Methods.STOP)
  }

  seek(position: number) {
    this.operate(Methods.SEEK, { position })
  }

  destroy() {
    this.operate(Methods.DESTROY)
    this.destroyed = true
    this.removaAllListener()
  }

  onCanplay(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_CANPLAY), callback)
  }

  offCanplay(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_CANPLAY), callback)
  }

  onPlay(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_PLAY), callback)
  }

  offPlay(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_PLAY), callback)
  }

  onPause(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_PAUSE), callback)
  }

  offPause(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_PAUSE), callback)
  }

  onStop(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_STOP), callback)
  }

  offStop(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_STOP), callback)
  }

  onEdned(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_ENDED), callback)
  }

  offEnded(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_ENDED), callback)
  }

  onTimeUpdate(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_TIME_UPDATE), callback)
  }

  offTimeUpdate(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_TIME_UPDATE), callback)
  }

  onError(callback: (res: InnerAudioContextErrorCallbackResult) => void) {
    addEvent(this.innerEventName(Events.ON_ERROR), callback)
  }

  offError(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_ERROR), callback)
  }

  onWaiting(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_WAITING), callback)
  }

  offWaiting(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_WAITING), callback)
  }

  onSeeking(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_SEEKING), callback)
  }

  offSeeking(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_SEEKING), callback)
  }

  onSeeked(callback: () => void) {
    addEvent(this.innerEventName(Events.ON_SEEKED), callback)
  }

  offSeeked(callback: () => void) {
    removeEvent(this.innerEventName(Events.ON_SEEKED), callback)
  }
}

Object.values(Events).forEach(event => {
  const ev = getEventName(event)
  subscribe(ev, data => {
    dispatchEvent(ev, data)
  })
})

function useAudio(audioId: number) {
  const ids = new Map<string, number>()

  function createListener(event: Events, callback: (data: any) => void) {
    const id = addEvent<{ audioId: number }>(getEventName(event), data => {
      if (data.audioId === audioId) {
        callback(data)
      }
    })
    ids.set(event, id)
    return id
  }

  return {
    onCanplay: (callback: (res: { duration: number }) => void) => {
      return createListener(Events.ON_CANPLAY, callback)
    },
    onPlay: (callback: () => void) => {
      return createListener(Events.ON_PLAY, callback)
    },
    onStop: (callback: () => void) => {
      return createListener(Events.ON_STOP, callback)
    },
    onEnded: (callback: () => void) => {
      return createListener(Events.ON_ENDED, callback)
    },
    onPause: (callback: () => void) => {
      return createListener(Events.ON_PAUSE, callback)
    },
    onWaiting: (callback: () => void) => {
      return createListener(Events.ON_WAITING, callback)
    },
    onError: (callback: (res: InnerAudioContextErrorCallbackResult) => void) => {
      return createListener(Events.ON_ERROR, callback)
    },
    onSeeking: (callback: () => void) => {
      return createListener(Events.ON_SEEKING, callback)
    },
    onSeeked: (callback: () => void) => {
      return createListener(Events.ON_SEEKED, callback)
    },
    onTimeUpdate: (callback: (res: { time: number }) => void) => {
      return createListener(Events.ON_TIME_UPDATE, callback)
    },
    onBufferUpdate: (callback: (res: { bufferTime: number }) => void) => {
      return createListener(Events.ON_BUFFER_UPDATE, callback)
    },
    removaAllListener: () => {
      ids.forEach((id, event) => removeEvent(event, id))
    }
  }
}

export function createInnerAudioContext() {
  return new InnerAudioContext()
}

interface SetInnerAudioOptionOptions {
  mixWithOther?: boolean
  obeyMuteSwitch?: boolean
  speakerOn?: boolean
  success?: SetInnerAudioOptionSuccessCallback
  fail?: SetInnerAudioOptionFailCallback
  complete?: SetInnerAudioOptionCompleteCallback
}

type SetInnerAudioOptionSuccessCallback = (res: GeneralCallbackResult) => void

type SetInnerAudioOptionFailCallback = (res: GeneralCallbackResult) => void

type SetInnerAudioOptionCompleteCallback = (res: GeneralCallbackResult) => void

export function setInnerAudioOption<
  T extends SetInnerAudioOptionOptions = SetInnerAudioOptionOptions
>(options: T): AsyncReturn<T, SetInnerAudioOptionOptions> {
  return wrapperAsyncAPI(options => {
    const event = "setInnerAudioOption"
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
