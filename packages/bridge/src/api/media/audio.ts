import { clamp, addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"
import { invoke, subscribe } from "../../bridge"

interface InnerAudioContextErrorCallbackResult {
  errMsg: string
  errCode: 10001 | 10002 | 10003 | 10004 | -1
}

let audioId = 0

const enum Methods {
  PLAY = "play",
  PAUSE = "pause",
  STOP = "stop",
  SEEK = "seek",
  DESTORY = "destroy",
  SET_VOLUME = "setVolume",
  SET_SRC = "setSrc",
  SET_PLAYBACK_RATE = "setPlaybackRate"
}

const PREFIX = "MODULE_AUDIO_CONTEXT_"

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
  ON_TIME_UPDATE = "ON_TIME_UPDATE"
}

const getEventName = (event: Events) => PREFIX + event

class InnerAudioContext {
  private readonly id: number = audioId++

  private _src: string = ""

  private _volume: number = 1

  startTime: number = 0

  autoplay: boolean = false

  loop: boolean = false

  private _playbackRate: number = 1

  private _duration: number = 0

  private _currentTime: number = 0

  private _paused: boolean = false

  readonly buffered: number = 0

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
      removaAllListener
    } = useAudio(this.id)

    onCanplay(({ duration }) => {
      this._duration = duration
      dispatchEvent(this.innerEventName(Events.ON_CANPLAY), undefined)
      this.seek(this.startTime)
    })

    onPlay(() => {
      this._paused = false
      dispatchEvent(this.innerEventName(Events.ON_PLAY), undefined)
    })

    onPause(() => {
      this._paused = true
      dispatchEvent(this.innerEventName(Events.ON_PAUSE), undefined)
    })

    onStop(() => {
      this._paused = true
      dispatchEvent(this.innerEventName(Events.ON_STOP), undefined)
    })

    onEnded(() => {
      this._paused = true
      if (this.loop) {
        this.seek(0)
        this.play()
      }
      dispatchEvent(this.innerEventName(Events.ON_ENDED), undefined)
    })

    onError(res => {
      this._paused = true
      dispatchEvent(this.innerEventName(Events.ON_ERROR), res)
    })

    onTimeUpdate(({ time }) => {
      this._currentTime = time
      dispatchEvent(this.innerEventName(Events.ON_TIME_UPDATE), undefined)
    })

    onSeeking(() => {
      dispatchEvent(this.innerEventName(Events.ON_SEEKING), undefined)
    })

    onSeeked(() => {
      dispatchEvent(this.innerEventName(Events.ON_SEEKED), undefined)
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

  private operate(method: Methods, data: Record<string, any> = {}) {
    invoke("operateInnerAudioContext", {
      audioId: this.id,
      method,
      data
    })
  }

  play() {
    if (this.src === "") {
      console.error("[NZoth] InnerAudioContext src is empty")
      return
    }
    this.operate(Methods.PLAY, {
      src: this.src,
      startTime: this.startTime,
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
    this.operate(Methods.DESTORY)
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
    onError: (
      callback: (res: InnerAudioContextErrorCallbackResult) => void
    ) => {
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
    removaAllListener: () => {
      ids.forEach((id, event) => removeEvent(event, id))
    }
  }
}

export function createInnerAudioContext() {
  return new InnerAudioContext()
}
