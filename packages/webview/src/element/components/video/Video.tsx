import {
  reactive,
  onMounted,
  onUnmounted,
  ref,
  watch,
  computed,
  getCurrentInstance,
  defineComponent,
  PropType,
  withDirectives,
  VNode
} from "vue"
import { JSBridge } from "../../../bridge"
import { useTongceng } from "../../composables/useTongceng"
import { vTap } from "../../directive/tap"
import { useVideo } from "../../composables/useVideo"
import { secondsToDuration } from "../../utils/format"
import { Touch } from "../../composables/useTouch"
import { clamp } from "@evoker/shared"
import { getVolume, setVolume, setScreenBrightness, getScreenBrightness } from "@evoker/bridge"
import { classNames } from "../../utils"
import Loading from "../loading"
import VideoProgress from "./VideoProgress"
import VideoScreenBrightness from "./VideoScreenBrightness"
import VideoButton from "./VideoButton"

const props = {
  src: String,
  duration: { type: Number, required: false },
  controls: { type: Boolean, default: true },
  autoplay: { type: Boolean, default: false },
  loop: { type: Boolean, default: false },
  muted: { type: Boolean, default: false },
  initialTime: { type: Number, default: 0 },
  direction: { type: Number as PropType<0 | 90 | -90>, default: undefined },
  showProgress: { type: Boolean, default: true },
  showFullscreenBtn: { type: Boolean, default: true },
  showPlayBtn: { type: Boolean, default: true },
  showCenterPlayBtn: { type: Boolean, default: true },
  showMuteBtn: { type: Boolean, default: false },
  enableProgressGesture: { type: Boolean, default: true },
  enablePlayGesture: { type: Boolean, default: false },
  objectFit: { type: String as PropType<"contain" | "fill" | "cover">, default: "contain" },
  poster: { type: String, required: false },
  title: { type: String, required: false },
  playBtnPosition: { type: String as PropType<"bottom" | "center">, default: "bottom" },
  vslideGesture: { type: Boolean, default: false },
  vslideGestureInFullscreen: { type: Boolean, default: true },
  showScreenLockButton: { type: Boolean, default: false }
}

const emits = [
  "play",
  "pause",
  "ended",
  "timeupdate",
  "fullscreenchange",
  "waiting",
  "error",
  "progress",
  "loadedmetadata",
  "controlstoggle",
  "seekcomplete"
]

export default defineComponent({
  name: "ev-video",
  props,
  emits,
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const viewRef = ref<HTMLElement>()

    const {
      tongcengKey,
      nativeId: videoPlayerId,
      tongcengRef,
      tongcengHeight,
      insertContainer,
      updateContainer
    } = useTongceng()

    const {
      onLoadedData,
      onPlay,
      onPause,
      onEnded,
      onError,
      timeUpdate,
      bufferUpdate,
      fullscreenChange,
      seekComplete,
      waiting
    } = useVideo(videoPlayerId)

    const enum Methods {
      PLAY = "play",
      PAUSE = "pause",
      STOP = "stop",
      MUTE = "mute",
      FULLSCREEN = "fullscreen",
      SEEK = "seek",
      REMOVE = "remove",
      REPLAY = "replay",
      CHANGE_URL = "changeURL",
      SET_PLAYBACK_RAGE = "setPlaybackRate"
    }

    const videoData = reactive({
      playing: false,
      bufferTime: 0,
      currentTime: 0,
      duration: 0,
      panTime: 0,
      touching: false,
      muted: false,
      fullscreen: false,
      width: 0,
      height: 0,
      showPoster: true
    })

    const showCenterPlayCover = ref(true)

    const isShowControl = ref(true)

    const isLocked = ref(false)

    const isBufferLoading = ref(false)

    let controlAutoHiddenTimer: ReturnType<typeof setTimeout>

    const screenWidth = window.screen.width

    const screenHeight = window.screen.height

    const tongcengSize = computed(() => {
      if (videoData.fullscreen) {
        let width = screenHeight
        let height = screenWidth
        if (getDirection() === 0) {
          width = screenWidth
          height = screenHeight
        }
        return `width: ${width}px; height:${height}px; position: fixed;`
      } else {
        return `width: 100%; height: 100%;`
      }
    })

    const getDirection = () => {
      let direction = props.direction
      if (direction == null) {
        if (videoData.width === 0 || videoData.height === 0) {
          direction = -90
        } else {
          direction = videoData.width > videoData.height ? -90 : 0
        }
      }
      return direction
    }

    const operateVideoPlayer = (method: Methods, data: Record<string, any> = {}) => {
      JSBridge.invoke("operateVideoPlayer", {
        videoPlayerId,
        method,
        data
      })
    }

    onLoadedData(data => {
      videoData.duration = props.duration || data.duration
      videoData.width = data.width
      videoData.height = data.height
      props.initialTime > 0 && seekTo(props.initialTime)
      emit("loadedmetadata", {
        duration: data.duration,
        width: videoData.width,
        height: videoData.height
      })
    })

    onPlay(() => {
      videoData.playing = true
      videoData.showPoster = false
      emit("play", {})

      showControl(isShowControl.value)
    })

    onPause(() => {
      videoData.playing = false
      emit("pause", {})
    })

    onEnded(() => {
      emit("ended", {})
      if (props.loop) {
        operateVideoPlayer(Methods.REPLAY)
        props.initialTime > 0 && seekTo(props.initialTime)
      }
    })

    onError(data => {
      videoData.playing = false
      emit("error", { error: data.error })
    })

    timeUpdate(data => {
      videoData.currentTime = data.currentTime
      emit("timeupdate", {
        currentTime: videoData.currentTime,
        duration: videoData.duration
      })
    })

    bufferUpdate(data => {
      videoData.bufferTime = data.bufferTime
      emit("progress", { buffered: clamp(data.bufferTime / videoData.duration, 0, 1) })
    })

    fullscreenChange(() => {
      const direction = getDirection() === 0 ? "vertical" : "horizontal"
      emit("fullscreenchange", { fullScreen: videoData.fullscreen, direction })
    })

    seekComplete(data => {
      isSeekingFromGesture.value = false
      emit("seekcomplete", { position: data.position })
    })

    waiting(data => {
      isBufferLoading.value = data.isBufferLoading
      isBufferLoading.value && emit("waiting", {})
    })

    watch(
      () => tongcengSize.value,
      () => {
        setTimeout(() => {
          updateContainer()
        }, 100)
      }
    )

    watch(isShowControl, show => {
      emit("controlstoggle", { show })
    })

    watch(
      () => props.src,
      newValue => {
        videoData.playing = false
        operateVideoPlayer(Methods.CHANGE_URL, {
          url: newValue,
          objectFit: props.objectFit,
          muted: props.muted
        })
      }
    )

    watch(
      () => props.muted,
      newValue => {
        videoData.muted = newValue
      },
      { immediate: true }
    )

    watch(
      () => props.duration,
      newValue => {
        newValue && (videoData.duration = newValue)
      },
      { immediate: true }
    )

    onMounted(() => {
      setTimeout(() => {
        insert()
      }, 10)
    })

    onUnmounted(() => {
      operateVideoPlayer(Methods.REMOVE)
    })

    const insert = () => {
      insertContainer(success => {
        if (success) {
          JSBridge.invoke(
            "insertVideoPlayer",
            {
              parentId: tongcengKey,
              videoPlayerId,
              url: props.src,
              objectFit: props.objectFit,
              muted: props.muted,
              loop: props.loop
            },
            result => {
              if (result.errMsg) {
              } else {
                if (props.autoplay) {
                  playSwitch()
                }
              }
            }
          )
        }
      })
    }

    const clickCenterPlayButton = () => {
      showCenterPlayCover.value = false
      playSwitch()
    }

    const play = () => {
      operateVideoPlayer(Methods.PLAY)
      showControl()
    }

    const pause = () => {
      operateVideoPlayer(Methods.PAUSE)
      showControl()
    }

    const playSwitch = () => {
      videoData.playing ? pause() : play()
    }

    const seekTo = (position: number) => {
      operateVideoPlayer(Methods.SEEK, { position })
    }

    const setPlaybackRate = (rate: number) => {
      operateVideoPlayer(Methods.SET_PLAYBACK_RAGE, { rate })
    }

    const mutedSwitch = () => {
      const muted = !videoData.muted
      instance.props.muted = muted
      videoData.muted = muted
      operateVideoPlayer(Methods.MUTE, { muted })
      showControl()
    }

    const enterFullScreen = (direction = getDirection()) => {
      videoData.fullscreen = true
      viewRef.value!.style.zIndex = "100000000"
      viewRef.value!.style.overflow = "visible"
      operateVideoPlayer(Methods.FULLSCREEN, {
        enter: videoData.fullscreen,
        direction
      })
      showControl()
    }

    const exitFullScreen = () => {
      videoData.fullscreen = false
      viewRef.value!.style.zIndex = ""
      viewRef.value!.style.overflow = ""
      operateVideoPlayer(Methods.FULLSCREEN, {
        enter: videoData.fullscreen,
        direction: 0
      })
      showControl()
    }

    const fullScreenSwitch = () => {
      videoData.fullscreen ? exitFullScreen() : enterFullScreen()
    }

    let clickTimes = 0

    let doubleClickTimer: ReturnType<typeof setTimeout>

    const showOrHideControl = () => {
      if (props.showCenterPlayBtn && showCenterPlayCover.value) {
        return
      }

      if (props.enablePlayGesture) {
        clickTimes += 1
        clearTimeout(doubleClickTimer)
        if (clickTimes === 2) {
          clickTimes = 0
          if (!isLocked.value) {
            playSwitch()
            showControl(true)
          }
        } else {
          doubleClickTimer = setTimeout(() => {
            clickTimes = 0
            showControl(!isShowControl.value)
          }, 200)
        }
      } else {
        showControl(!isShowControl.value)
      }
    }

    const showControl = (show = true) => {
      if (!props.controls) {
        return
      }
      clearTimeout(controlAutoHiddenTimer)
      isShowControl.value = show

      if (isShowControl.value) {
        controlAutoHiddenTimer = setTimeout(() => {
          isShowControl.value = false
        }, 5000)
      }
    }

    const controlsLock = () => {
      isLocked.value = !isLocked.value
      showControl()
    }

    const touch = Touch()

    const isSeekingFromGesture = ref(false)

    const isShowSeekTime = ref(false)

    const seekingTime = ref(0)

    let isMoveProgressSlider = false

    const currentTime = computed(() => {
      if (isSeekingFromGesture.value) {
        return seekingTime.value
      } else {
        return videoData.currentTime
      }
    })

    const onStartSlideProgress = (ev: TouchEvent) => {
      ev.preventDefault()
      ev.stopPropagation()
      touch.start(ev)

      isMoveProgressSlider = false
      seekingTime.value = videoData.currentTime
      isSeekingFromGesture.value = true
      isShowSeekTime.value = true
      clearTimeout(controlAutoHiddenTimer)
      isShowControl.value = true
    }

    const onMoveSlideProgress = (ev: TouchEvent, el: HTMLElement) => {
      ev.preventDefault()
      ev.stopPropagation()
      touch.move(ev)

      const rect = el.getBoundingClientRect()
      const x = touch.deltaX.value
      const percent = x / rect.width
      let value = videoData.duration * percent
      value = Math.floor(value)
      value = clamp(value, 0, videoData.duration)
      seekingTime.value = value
      isMoveProgressSlider = true
    }

    const onEndSlideProgress = (ev: TouchEvent) => {
      ev.preventDefault()
      ev.stopPropagation()
      touch.reset()
      showControl()
      isShowSeekTime.value = false
      if (isMoveProgressSlider) {
        seekTo(seekingTime.value)
      } else {
        isSeekingFromGesture.value = false
      }
    }

    const enum GestureEvents {
      NONE = 0,
      SEEK,
      VOLUME,
      BRIGHTNESS
    }

    let currentGestureEvent = GestureEvents.NONE

    const screenBrightness = ref(-1)

    const systemVolume = ref(-1)

    const isShowScreenBrightnessToast = ref(false)

    let showScreenBrightnessToastTimer: ReturnType<typeof setTimeout>

    const onStartPanGesture = (ev: TouchEvent) => {
      ev.preventDefault()
      ev.stopPropagation()
      touch.start(ev)

      currentGestureEvent = GestureEvents.NONE
    }

    const onMovePanGesture = async (ev: TouchEvent) => {
      ev.preventDefault()
      ev.stopPropagation()

      if (isLocked.value || (props.showCenterPlayBtn && showCenterPlayCover.value)) {
        return
      }

      touch.move(ev)

      const visideEnabled = () => {
        let result = true
        if (videoData.fullscreen) {
          result = props.vslideGestureInFullscreen
        } else {
          result = props.vslideGesture
        }
        return result
      }

      const rect = viewRef.value!.getBoundingClientRect()

      if (currentGestureEvent === GestureEvents.NONE) {
        if (touch.offsetX.value > touch.offsetY.value) {
          if (!props.enableProgressGesture) {
            return
          }
          currentGestureEvent = GestureEvents.SEEK
        } else if (touch.startX.value - rect.left > rect.width * 0.5) {
          if (!visideEnabled()) {
            return
          }
          currentGestureEvent = GestureEvents.VOLUME
          const res = await getVolume({})
          systemVolume.value = res.volume
        } else {
          if (!visideEnabled()) {
            return
          }
          currentGestureEvent = GestureEvents.BRIGHTNESS
          const res = await getScreenBrightness({})
          screenBrightness.value = res.value
        }
      }

      if (currentGestureEvent === GestureEvents.SEEK) {
        isMoveProgressSlider = false
        seekingTime.value = videoData.currentTime
        isSeekingFromGesture.value = true
        isShowSeekTime.value = true

        const x = touch.deltaX.value
        const percent = x / rect.width
        let value = videoData.duration * percent
        value = Math.floor(value)
        value = clamp(value, 0, videoData.duration)
        seekingTime.value = value
        clearTimeout(controlAutoHiddenTimer)
        isShowControl.value = true
      } else if (currentGestureEvent === GestureEvents.VOLUME) {
        const position = touch.startY.value - (touch.deltaY.value + touch.startY.value)
        const percent = position / (rect.height * 0.5)
        const value = clamp(systemVolume.value + percent, 0, 1)

        touch.startY.value = touch.deltaY.value + touch.startY.value

        setVolume({ volume: value })

        systemVolume.value = value

        clearTimeout(controlAutoHiddenTimer)
        isShowControl.value = true
      } else if (currentGestureEvent === GestureEvents.BRIGHTNESS) {
        const position = touch.startY.value - (touch.deltaY.value + touch.startY.value)
        const percent = position / (rect.height * 0.5)
        const value = clamp(screenBrightness.value + percent, 0, 1)

        touch.startY.value = touch.deltaY.value + touch.startY.value

        setScreenBrightness({ value })

        screenBrightness.value = value

        clearTimeout(showScreenBrightnessToastTimer)
        isShowScreenBrightnessToast.value = true

        showScreenBrightnessToastTimer = setTimeout(() => {
          isShowScreenBrightnessToast.value = false
        }, 1500)
        clearTimeout(controlAutoHiddenTimer)
        isShowControl.value = true
      }
    }

    const onEndPanGesture = (ev: TouchEvent) => {
      touch.reset()

      if (currentGestureEvent !== GestureEvents.NONE) {
        showControl()
      }
      if (currentGestureEvent === GestureEvents.SEEK) {
        isShowSeekTime.value = false
        seekTo(seekingTime.value)
      }
    }

    const operateFromService = (options: { method: string; data: Record<string, any> }) => {
      const { method, data } = options
      switch (method) {
        case Methods.PLAY:
          play()
          break
        case Methods.PAUSE:
          pause()
          break
        case Methods.STOP:
          operateVideoPlayer(method)
          showControl()
          break
        case Methods.SEEK:
          seekTo(data.position)
          break
        case Methods.SET_PLAYBACK_RAGE:
          setPlaybackRate(data.rate)
          break
        case "requestFullScreen":
          enterFullScreen(data.direction)
          break
        case "exitFullScreen":
          exitFullScreen()
          break
        default:
          break
      }
    }

    expose({
      getContextId: () => videoPlayerId,
      operate: operateFromService
    })

    const renderControls = () => {
      const centerPlayButton = () => {
        if (props.playBtnPosition === "center" && !isLocked.value) {
          return (
            <VideoButton
              class="video__control__center__playButton"
              style="width: 36px; height: 36px"
              type={videoData.playing ? "pause" : "play"}
              onClick={playSwitch}
            ></VideoButton>
          )
        }
      }

      const bottomBar = () => {
        return withDirectives(
          (
            <div
              v-show={!isLocked.value}
              class={classNames("ev-video__control__bar", {
                "ev-video__control__bar--fullscreen": videoData.fullscreen
              })}
            >
              {props.showPlayBtn && props.playBtnPosition === "bottom" ? (
                <VideoButton
                  type={videoData.playing ? "pause" : "play"}
                  onClick={playSwitch}
                ></VideoButton>
              ) : null}
              {props.showProgress ? (
                <VideoProgress
                  currentTime={currentTime.value}
                  bufferTime={videoData.bufferTime}
                  duration={videoData.duration}
                  onSlideStart={onStartSlideProgress}
                  onSliding={onMoveSlideProgress}
                  onSlideEnd={onEndSlideProgress}
                />
              ) : null}
              {rightButtons()}
            </div>
          ) as VNode,
          [[vTap, showControl, "", { stop: true }]]
        )
      }

      const rightButtons = () => {
        return (
          <div class="ev-video__control__bar__right">
            {props.showMuteBtn ? (
              <VideoButton
                type={videoData.muted ? "mute-on" : "mute-off"}
                style="margin-left: 8px"
                onClick={mutedSwitch}
              ></VideoButton>
            ) : null}
            {props.showFullscreenBtn ? (
              <VideoButton
                type="fullscreen"
                style="margin-left: 8px"
                onClick={fullScreenSwitch}
              ></VideoButton>
            ) : null}
          </div>
        )
      }

      return (
        <div v-show={isShowControl.value} class="ev-video__control">
          <VideoButton
            v-show={videoData.fullscreen && props.showScreenLockButton}
            class="ev-video__control__lock"
            type={isLocked.value ? "lock" : "unlock"}
            onClick={controlsLock}
          ></VideoButton>
          <div v-show={videoData.fullscreen && !isLocked.value} class="ev-video__control__bar__top">
            <VideoButton type="back" onClick={fullScreenSwitch}></VideoButton>
            <div class="ev-video__title">{props.title}</div>
          </div>
          {centerPlayButton()}
          {bottomBar()}
        </div>
      )
    }

    const renderTongceng = () => {
      return (
        <div
          class="ev-native__tongceng ev-video__native"
          ref={tongcengRef}
          id={tongcengKey}
          style={tongcengSize.value}
        >
          <div style={{ width: "100%", height: tongcengHeight }}></div>
        </div>
      )
    }

    const renderCover = () => {
      if (props.showCenterPlayBtn && showCenterPlayCover.value) {
        return (
          <div class="ev-video__cover">
            {withDirectives(
              (<div class="ev-video__cover__play ev-video__icon--play"></div>) as VNode,
              [[vTap, clickCenterPlayButton, "", { stop: true }]]
            )}
            <span class="ev-video__cover__duration">{secondsToDuration(videoData.duration)}</span>
          </div>
        )
      } else if (props.controls) {
        return renderControls()
      }
    }

    const renderWrapper = () => {
      return (
        <div class="ev-video__wrapper" style={tongcengSize.value}>
          {isBufferLoading.value ? (
            <Loading class="ev-video__loading" size="50px" color="white" />
          ) : null}
          {props.poster && videoData.showPoster && (
            <img class="ev-video__poster" src={props.poster} />
          )}
          {renderCover()}
          <VideoScreenBrightness
            v-show={isShowScreenBrightnessToast.value}
            value={screenBrightness.value}
          ></VideoScreenBrightness>
          <div v-show={isShowSeekTime.value} class="ev-video__seektime">
            {secondsToDuration(currentTime.value)}
          </div>
        </div>
      )
    }

    return () => {
      return withDirectives(
        (
          <ev-video
            ref={viewRef}
            onTouchstart={onStartPanGesture}
            onTouchmove={onMovePanGesture}
            onTouchend={onEndPanGesture}
            onTouchcancel={onEndPanGesture}
          >
            {renderTongceng()}
            {renderWrapper()}
            <div class="ev-video__slot" style={tongcengSize.value}></div>
          </ev-video>
        ) as VNode,
        [[vTap, showOrHideControl, "", { stop: true }]]
      )
    }
  }
})
