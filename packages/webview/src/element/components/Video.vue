<template>
  <nz-video ref="viewRef" @touchstart="onStartPanGesture" @touchmove="onMovePanGesture" @touchend="onEndPanGesture"
    @touchcancel="onEndPanGesture" v-tap.stop="showOrHideControl">
    <div class="nz-video__native" ref="containerRef" :id="tongcengKey" :style="tongcengSize">
      <div style="width: 100%;" :style="height"></div>
    </div>
    <img v-if="poster && videoData.showPoster" class="nz-video__poster"
      :style="{ position: videoData.fullscreen ? 'fixed' : 'absolute' }" :src="poster" />
    <div v-if="showCenterPlayBtn && showCenterPlayCover" class="nz-video__cover">
      <div class="nz-video__cover__play nz-video__icon--play" v-tap.stop="clickCenterPlayButton"></div>
      <span class="nz-video__cover__duration">{{ secondsToDuration(videoData.duration) }}</span>
    </div>
    <template v-else-if="controls">
      <div v-show="isShowControl" class="nz-video__control" :style="tongcengSize">
        <div v-show="videoData.fullscreen && showScreenLockButton"
          class="nz-video__control__button nz-video__control__lock"
          :class="`nz-video__icon--${isLocked ? 'lock' : 'unlock'}`" v-tap.stop="controlsLock"></div>
        <div v-show="videoData.fullscreen && !isLocked" class="nz-video__control__bar__top">
          <div class="nz-video__control__button nz-video__icon--back" v-tap.stop="enterFullscreen"></div>
          <div class="nz-video__title">{{ title }}</div>
        </div>
        <div v-if="playBtnPosition === 'center' && !isLocked"
          class="nz-video__control__button nz-video__control__center__playButton"
          :class="`nz-video__icon--${videoData.playing ? 'pause' : 'play'}`" style="width: 36px;height: 36px;"
          v-tap.stop="play"></div>
        <div v-show="!isLocked" class="nz-video__control__bar"
          :class="videoData.fullscreen ? 'nz-video__control__bar--fullscreen' : ''" v-tap.stop="showControl">
          <div v-if="showPlayBtn && playBtnPosition === 'bottom'" class="nz-video__control__button" v-tap.stop="play">
            <div class="nz-video__control__button" :class="`nz-video__icon--${videoData.playing ? 'pause' : 'play'}`">
            </div>
          </div>
          <template v-if="showProgress">
            <span class="nz-video__control__progress__time" style="margin-right: 8px">{{
                secondsToDuration(currentTime)
            }}</span>
            <div ref="progressRef" class="nz-video__control__progress">
              <div class="nz-video__control__progress__buffer"
                :style="{ width: dutationPercent(videoData.bufferTime) }">
              </div>
              <div class="nz-video__control__progress__played" :style="{ width: dutationPercent(currentTime) }">
              </div>
              <div class="nz-video__control__progress__handle" :style="{ left: dutationPercent(currentTime) }"
                @touchstart="onStartSlideProgress" @touchmove="onMoveSlideProgress" @touchend="onEndSlideProgress"
                @touchcancel="onEndSlideProgress">
                <div class="nz-video__control__progress__ball"></div>
              </div>
            </div>
            <span class="nz-video__control__progress__time" style="margin-left: 8px">{{
                secondsToDuration(videoData.duration)
            }}</span>
          </template>
          <div class="nz-video__control__bar__right">
            <div v-if="showMuteBtn" class="nz-video__control__button"
              :class="`nz-video__icon--mute-${videoData.muted ? 'on' : 'off'}`" style="margin-left: 8px"
              v-tap.stop="mutedOnOff"></div>
            <div v-if="showFullscreenBtn" class="nz-video__control__button nz-video__icon--fullscreen"
              style="margin-right: 8px" v-tap.stop="enterFullscreen"></div>
          </div>
        </div>
      </div>
    </template>
    <video-screen-brightness v-show="isShowScreenBrightnessToast" :value="screenBrightness"
      :style="{ position: videoData.fullscreen ? 'fixed' : 'absolute' }"></video-screen-brightness>
  </nz-video>
</template>

<script lang="ts" setup>
import { reactive, onMounted, onUnmounted, ref, watch, computed } from "vue"
import { NZJSBridge } from "../../bridge"
import useNative from "../use/useNative"
import { vTap } from "../directive/tap"
import usePlayer from "../listener/video"
import { secondsToDuration } from "../utils/format"
import { Touch } from "../use/useTouch"
import { clamp } from "@nzoth/shared"
import { getVolume, setVolume, setScreenBrightness, getScreenBrightness } from "@nzoth/bridge"
import VideoScreenBrightness from "./VideoScreenBrightness.vue"

const emit = defineEmits([
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
])

const props = withDefaults(defineProps<{
  src: string
  duration?: number
  controls?: boolean
  autoplay?: boolean
  loop?: boolean
  muted?: boolean
  initialTime?: number
  direction?: "" | 0 | 90 | -90
  showProgress?: boolean
  showFullscreenBtn?: boolean
  showPlayBtn?: boolean
  showCenterPlayBtn?: boolean
  showMuteBtn?: boolean
  enableProgressGesture?: boolean
  enablePlayGesture?: boolean
  objectFit?: "contain" | "fill" | "cover"
  poster?: string
  title?: string
  playBtnPosition?: "bottom" | "center"
  vslideGesture?: boolean
  vslideGestureInFullscreen?: boolean
  showCastingButton?: boolean
  enableAutoRotation?: boolean
  showScreenLockButton?: boolean
  showSnapshotButton?: boolean
  referrerPolicy?: "origin" | "no-referrer"
}>(), {
  controls: true,
  autoplay: false,
  loop: false,
  muted: false,
  initialTime: 0,
  direction: "",
  showProgress: true,
  showFullscreenBtn: true,
  showPlayBtn: true,
  showCenterPlayBtn: true,
  showMuteBtn: false,
  enableProgressGesture: true,
  enablePlayGesture: false,
  objectFit: "contain",
  playBtnPosition: "bottom",
  vslideGesture: false,
  vslideGestureInFullscreen: true,
  showCastingButton: false,
  enableAutoRotation: false,
  showSnapshotButton: false,
  referrerPolicy: "no-referrer",
})

const viewRef = ref<HTMLElement>()

const {
  tongcengKey,
  nativeId: videoPlayerId,
  containerRef,
  height,
  insertContainer,
  updateContainer
} = useNative()

const {
  onLoadedData,
  onPlay,
  onPause,
  onEnded,
  onError,
  timeUpdate,
  bufferUpdate
} = usePlayer(videoPlayerId)

const enum Methods {
  PLAY = "play",
  PAUSE = "pause",
  MUTE = "mute",
  FULLSCREEN = "fullscreen",
  SEEK = "seek",
  REMOVE = "remove",
  REPLAY = "replay",
  CHANGE_URL = "changeURL"
}

const operateVideoPlayer = (method: Methods, data: Record<string, any> = {}) => {
  NZJSBridge.invoke("operateVideoPlayer", {
    videoPlayerId,
    method,
    data
  })
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
  if (direction === "") {
    direction = videoData.width > videoData.height ? -90 : 0
  }
  return direction
}

watch(() => tongcengSize.value, () => {
  setTimeout(() => {
    updateContainer()
  }, 100)
})

onLoadedData(data => {
  videoData.duration = props.duration || data.duration
  videoData.width = data.width
  videoData.height = data.height
  props.initialTime > 0 && seekTo(props.initialTime)
})

onPlay(() => {
  videoData.playing = true
  videoData.showPoster = false
  emit("play", {})

  clearTimeout(controlAutoHiddenTimer)
  if (props.controls) {
    controlAutoHiddenTimer = setTimeout(() => {
      isShowControl.value = false
    }, 5000)
  }
})

onPause(() => {
  videoData.playing = false
  emit("pause", {})
})

onEnded(() => {
  if (props.loop) {
    operateVideoPlayer(Methods.REPLAY)
    props.initialTime > 0 && seekTo(props.initialTime)
  }
})

onError(() => {
  videoData.playing = false
})

timeUpdate(data => {
  videoData.currentTime = data.currentTime
})

bufferUpdate(data => {
  videoData.bufferTime = data.bufferTime
})

watch(() => props.src, (newValue) => {
  operateVideoPlayer(Methods.CHANGE_URL, { url: newValue })
})

watch(() => props.muted, (newValue) => {
  videoData.muted = newValue
}, { immediate: true })

watch(() => props.duration, (newValue) => {
  newValue && (videoData.duration = newValue)
}, { immediate: true })

onMounted(() => {
  setTimeout(() => {
    insert()
  }, 10)
})

onUnmounted(() => {
  operateVideoPlayer(Methods.REMOVE)
})

const insert = () => {
  insertContainer((success) => {
    if (success) {
      NZJSBridge.invoke("insertVideoPlayer", {
        parentId: tongcengKey,
        videoPlayerId,
        url: props.src,
        objectFit: props.objectFit,
        muted: props.muted,
        loop: props.loop,
      }, result => {
        if (result.errMsg) {

        } else {
          if (props.autoplay) {
            play()
          }
        }
      })
    }
  })
}

const clickCenterPlayButton = () => {
  showCenterPlayCover.value = false
  play()
}

const play = () => {
  operateVideoPlayer(videoData.playing ? Methods.PAUSE : Methods.PLAY)
  showControl()
}

const seekTo = (position: number) => {
  operateVideoPlayer(Methods.SEEK, { position })
}

const mutedOnOff = () => {
  videoData.muted = !videoData.muted
  operateVideoPlayer(Methods.MUTE, { muted: videoData.muted })
  showControl()
}

const enterFullscreen = () => {
  videoData.fullscreen = !videoData.fullscreen
  operateVideoPlayer(Methods.FULLSCREEN, { enter: videoData.fullscreen, direction: getDirection() })
  showControl()
}

const AUTO_HIDE_CONTROL_DELAY = 5000

let clickTimes = 0
let doubleClickTimer: ReturnType<typeof setTimeout>

const showOrHideControl = () => {
  if (props.showCenterPlayBtn && showCenterPlayCover.value) {
    return
  }

  const exec = (show: boolean) => {
    if (!props.controls) {
      return
    }
    clearTimeout(controlAutoHiddenTimer)
    isShowControl.value = show
    if (isShowControl.value) {
      controlAutoHiddenTimer = setTimeout(() => {
        isShowControl.value = false
      }, AUTO_HIDE_CONTROL_DELAY)
    }
  }

  if (props.enablePlayGesture) {
    clickTimes += 1
    clearTimeout(doubleClickTimer)
    if (clickTimes === 2) {
      clickTimes = 0
      if (!isLocked.value) {
        play()
        exec(true)
      }
    } else {
      doubleClickTimer = setTimeout(() => {
        clickTimes = 0
        exec(!isShowControl.value)
      }, 200)
    }
  } else {
    exec(!isShowControl.value)
  }
}

const showControl = () => {
  if (!props.controls) {
    return
  }
  clearTimeout(controlAutoHiddenTimer)
  isShowControl.value = true

  controlAutoHiddenTimer = setTimeout(() => {
    isShowControl.value = false
  }, AUTO_HIDE_CONTROL_DELAY)
}

const controlsLock = () => {
  isLocked.value = !isLocked.value
  showControl()
}

const dutationPercent = (x: number) => {
  const p = (x / videoData.duration) * 100
  return `${clamp(p, 0, 100)}%`
}

const touch = Touch()

const progressRef = ref<HTMLElement>()

const isSlidingProgress = ref(false)

const slidingTime = ref(0)

const currentTime = computed(() => {
  if (isSlidingProgress.value) {
    return slidingTime.value
  } else {
    return videoData.currentTime
  }
})

const onStartSlideProgress = (ev: TouchEvent) => {
  touch.start(ev)
  slidingTime.value = videoData.currentTime
  isSlidingProgress.value = true
}

const onMoveSlideProgress = (ev: TouchEvent) => {
  touch.move(ev)

  const rect = progressRef!.value?.getBoundingClientRect()!

  const x = touch.deltaX.value + touch.startX.value - rect.left
  const percent = x / rect.width
  let value = videoData.duration * percent
  value = Math.round(value)
  value = clamp(value, 0, videoData.duration)
  slidingTime.value = value
  isSlidingProgress.value = true
}

const onEndSlideProgress = (ev: TouchEvent) => {
  isSlidingProgress.value = false
  touch.reset()
  showControl()
  seekTo(slidingTime.value)
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
  touch.start(ev)

  slidingTime.value = videoData.currentTime

  currentGestureEvent = GestureEvents.NONE
}

const onMovePanGesture = async (ev: TouchEvent) => {
  ev.preventDefault()

  if (isLocked.value) {
    return
  }

  if (props.showCenterPlayBtn && showCenterPlayCover.value) {
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
    const x = touch.deltaX.value + touch.startX.value - rect.left
    const percent = x / rect.width
    let value = videoData.duration * percent
    value = Math.round(value)
    value = clamp(value, 0, videoData.duration)
    slidingTime.value = value
    isSlidingProgress.value = true
    showControl()
  } else if (currentGestureEvent === GestureEvents.VOLUME) {
    const position = touch.startY.value - (touch.deltaY.value + touch.startY.value)
    const percent = position / (rect.height * 0.5)
    const value = clamp(systemVolume.value + percent, 0, 1)

    touch.startY.value = touch.deltaY.value + touch.startY.value

    setVolume({ volume: value })

    systemVolume.value = value
    showControl()
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
    showControl()
  }
}

const onEndPanGesture = (ev: TouchEvent) => {
  isSlidingProgress.value = false
  touch.reset()

  if (currentGestureEvent === GestureEvents.SEEK) {
    seekTo(slidingTime.value)
  }
}

</script>

<style lang="less">
nz-video {
  display: inline-block;
  width: 300px;
  height: 225px;
  line-height: 0;
  overflow: hidden;
  position: relative;
  z-index: 0;
}

.nz-video {
  &__native {
    display: inline-block;
    position: absolute;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
    overflow: scroll;
    -webkit-overflow-scrolling: touch;
  }

  &__poster {
    position: absolute;
    width: 100%;
    height: 100%;
    object-fit: contain;
  }

  &__cover {
    position: absolute;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;

    &__play {
      width: 36px;
      height: 36px;
      background-position: 50% 50%;
      background-repeat: no-repeat;
      background-size: cover;
    }

    &__duration {
      font-size: 16px;
      line-height: 1;
      color: white;
      margin-top: 5px;
    }
  }

  &__title {
    text-align: left;
    color: #fff;
    font-size: 16px;
    width: 60%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__control {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    &__center__playButton {
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
    }

    &__bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: absolute;
      left: 0;
      right: 0;
      bottom: 0;
      height: 48px;
      background-image: linear-gradient(-180deg,
          transparent,
          rgba(0, 0, 0, 0.5));
      overflow: hidden;
      padding: 0 14px;

      &--fullscreen {
        padding-left: var(--safe-area-inset-left);
        padding-right: var(--safe-area-inset-right);
        padding-top: 0;
        padding-bottom: calc(var(--safe-area-inset-bottom) + 14px);
        height: 62px;
      }

      &__top {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        display: flex;
        align-items: center;
        background-image: linear-gradient(0deg,
            transparent,
            rgba(0, 0, 0, 0.5));
        height: 60px;
        line-height: 60px;
        padding-left: var(--safe-area-inset-left);
        padding-right: var(--safe-area-inset-right);
        padding-top: var(--safe-area-inset-top);
      }

      &__right {
        display: flex;
        align-items: center;
        justify-content: center;
      }
    }

    &__progress {
      flex-grow: 1;
      position: relative;
      background-color: hsla(0, 0%, 100%, 0.2);
      height: 2px;

      &__time {
        color: #fff;
        font-size: 11px;
        height: 24px;
        line-height: 24px;
        width: 5ch;
      }

      &__buffer {
        position: absolute;
        background-color: hsla(0, 0%, 100%, 0.5);
        width: 0;
        height: 100%;
        top: 0;
        transition: width 0.05s ease;
      }

      &__played {
        position: absolute;
        background-color: #fff;
        width: 0;
        height: 100%;
        top: 0;
      }

      &__handle {
        position: absolute;
        width: 12px;
        height: 12px;
        margin-left: -6px;
        top: -6px;
        left: 0%;
      }

      &__ball {
        background-color: #fff;
        border-radius: 50%;
        width: 100%;
        height: 100%;
      }
    }

    &__button {
      width: 24px;
      height: 24px;
      background-position: 50% 50%;
      background-repeat: no-repeat;
      background-size: cover;
      margin-right: 16px;
    }

    &__lock {
      position: absolute;
      left: var(--safe-area-inset-left);
      top: 50%;
      transform: translate(0, -50%);
    }
  }

  &__icon {
    &--play {
      background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAA2hJREFUeAHtm0+ITVEcx99DUkrRLKyoWVBkRBZTIpqFsmBjoSyUNGIQC2VBipWy0CgLNQsbsZAINaNEQjIl0/iXpJEJmUjK//F8Tkz95s17795z7rnXO39O/Zrf+fM753w/73ffe3PufaVSLJFAJBAJRAKRQCQQCdQnUKlUptTvDbgHMG3YI+wH1octCRjHROkAuY/J8ovKMWz6xNEBtgBiVNIR/hD+2gCRjJcsgNRzz9Ixe3xUQLV6VKraP1LvxMoBofkrtQpEUvU2AxYGBSmJSI1+9Wl3BJsWBKgaANI2PWdgh/eQ0tJoMO40fS3egmogXKdrhMGbvYSkQyHF2OuMmecVqBSidYd8I+AANtULULrqNcY/ZuwK5yFpCDYZ+pugU9hMZ0GZqDaIeUvMxv8FKdPXfyW2wI33stb2crn8ssA1S5OKXCzjWmuIH+Q12YcVdkDnUgZJvgNUOsmme7IxD9+lDJL626jcIZNOYDNkh23f1QySHIap7CKbLshGW74PgMZYXMTZCajXYw02/rp6idXSvp7GJ1xyuzFrunzKIAmtn4p6E38gG018a6RNFs8xZhlzqzsume+w+JpBkv0QlR1k01XZmNb3NYOk/rlUrpBN5zDtOywhZJCENUJlNdk0KBsb+SFkkNSvjncPyoYkPzRAiofWbfHQAP0EUHdS1sj+kAA9RXgH7z99EkCSHwKg70A4jC0Gzq0kINX9hZ2rVC9cUP0m62wDzDPT9XzNoA8A2QqYVVngKKg+ZtAZdO0BzHslMGvxCdALYKgz62tZoch4Hy4x9dF9FFtkG44C5XoG3UWDOtZI/a+DEq1TXM2gT4jswpbnCUeBdDGDzrNvdQb9RgnIu7gE6BUwugBzOW8ocn4XLrFRNnwcW1A0HAnKyOcAKu/SzwJLjTbXDEE50vnM3Huxyc2g03gPOQG6xLxzjDfVTIGWAQ0z34Zm0pd5L5YAqd97nMRyvceeWazJBBYADTBHu8naTsRkAPSF2P2YS9/D9F8TQ0C9xLXqr+ZghCagd4zf5KBM8y2nBKSeVu3BZpmv5GhkCkDqcZSVjsrLvu0GgNQT84cwP56YN0UFgIdYdblBw3zTOb2KA8Q67Os/QupXO1u8EmhDDFBasHYsjF8R2oAW54gEIoFIIBKIBCKBZiDwB2yVkq+Q4MhdAAAAAElFTkSuQmCC");
    }

    &--pause {
      background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAP1JREFUeAHt0kEKglAARVFt/7uqfZnRREi5fTJHRwiiq305vGlyESBAgAABAgQIEDhbYFmW+/r59rqfdf564GXnzr+89Etm5Pl5vUbuP7r3ynNvRy/h97cAoFgCIEAhENmCAIVAZAsCFAKRLQhQCES2IEAhENmCAIVAZAsCFAKRLQhQCES2IEAhENmCAIVAZAsCFAKRLQhQCES2IEAhENmCAIVAZAsCFAKRLQhQCES2IEAhENmCAIVAZAsCFAKRLQhQCES2IEAhENmCAIVAZAsCFAKRLQhQCES2oD8DPeL/t3nk3u1ze99H/mvk3r2z/EaAAAECBAgQIEDgU+AJTppqKsJmtP4AAAAASUVORK5CYII=");
    }

    &--mute {
      &-on {
        background-image: url("data:image/png;base64,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");
      }

      &-off {
        background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAASKADAAQAAAABAAAASAAAAACQMUbvAAAERklEQVR4Ae2b34uMURjHZ9D6cSE3ylC2kEItrhgK13shhcSNvWDJX+DCpXCn3A2utcmW8g9sZHbvFCVCibVcWCVudmPX55neMz3neN93zjtrNDPnPPXtPM/7nnPe5/nMzOOdeW2pFC0SiAQigUggEogEIoFIIBLoJwKLi4vD6H6i4X6qbUm1AGQA1ZC2BYKRJW3cD4uBUEF1TUb5b/uhxrZrAEQVzSggrrvQ9ua9vhASo2jOISLxG32s1+ssnD/Fp/UbYfIZHUA1CYwVvkAvL6DoCkrrN5Mc3yi1MYYJiMKrKK3f3OH4gHnhgwRE0Wn9Zp7jFw0YMwYFiGJz+42BosdgAFFoy36jwRg/CEAU6dVvDBQ9FgHE3CNor17f9T4Je/ebtGJ8ATHvNJpDX9DWtL266hhJ5vWbg77Jsk8NNS1tHSfPI/muZuwdzoa0uV1xjOQqqG6yVeMUfuP+xjdR5vsAGmTeB6TtGUHzdsH3epnzZDN0A82gTph1f5OZiHOCRFoCkiXM247k46XtsrNd+yG7CpxOWOr9jW+mJOQFSPZj7h4k1zP2E2eT77Vy57FRJ9458n3Ku9+kJch6b0CynvnXkLZ7afvqY2UdZPmyozr3Cv+xittx51l0vVwuz7Sz2KwhrRr+qInZL7ce5q9h7ks0aNYwDrHshYqLuwJImSTVFUZOhd5BkjRrTqhaxL2aV8yyvJN9eu4hdX1VtZ1U/l9ucID4OP2CwrgiIf/C7Vax5QYHKKl+zKJQKh1z4mYYKqAnEJB3krEh47hjkID4mP0GxCcFY4fyLTdIQAmBaUVivfItN2RAHxWJtcq33JAByc2qMX0jbI41xpABrVMkvivfckMGpL+ozlpUVBAkIG4Ml8Ngl+Ig389SLUhAkNiHVikiz5VvuaECGrEolEoTTtwMgwPEx2s11Z9qEiiVvuE/VbHlBgeI6o8jfd8zntxZW2BMsMI4BcZDvApL/U3on/xgViDnxlTylr5zxVl3y4mLh2zcLz+53qQWbY+K00hZwY798KP9YerQz8d+EG9OKbf4ITYaQJ187HOX/VcWzYw1Xj+5Mm8QvUfaLhW93n+ZT4YVVNeZJv4UYyceHO5k32nnehPEuT/w/xcYWRchOXlHWq9+UkChR0HuHu71OL8fzSZ7m0H66RZ3blfGJDqK5kzmyej9MJH5FmS3SM6fQ7rvyCPobe68ro5JuIrkVXWt5eNoFuQCksKZcwEJJPlPC/p5WFdzsZIj8QqqI9dy+xKTWwJKIJ1hrv72bl2/JwIKGEC3kWuZfYmJXoB6AoBvkhTt3ZeCBCQgKbyKWvalYAElkLL60iRgGvdLQQNKIElfsvoMsVijLzFa52RNkAaIrL4U9h+z6HcDkLL6EqcaFu6fQxlQYMjqS0LotZkX9AiIrL50NmgwbvGAOooeoDEU/6jXBRTjSCASiAQigUggEogEIoHOEvgDfljFmQRQo9sAAAAASUVORK5CYII=");
      }
    }

    &--fullscreen {
      background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAnJJREFUeAHtm79KBDEQxl3RVhELGy0sRSxtRa7QB1DxHcTqWhGxuNZSwcbOSq/yGXwBEbsr/IMgWFhoI7p+0xxLLmEm2T3ZPb7AwmZm8k3ut0lgs5exMRYSIAESIAESIAESIAES8BDIPDbVlOf5pBqkBGRZ9q2E9N3IN43Kct+QdvOLZj3kfYtpPmENRidnEHuMawPXlLVdKA56K+jse8jv2AXOlWNLqiLvNRq2rQ9oPCLLGWK3cZWGE5FzGKFbEN23CpsAgfo8BNesog2I27T20QQIYgtWwYbEzVr7aV2DfIv5JZI8WRN54r48tpDpHg6Z3qlFptR6SmMrIJ92Fwvdrc9RtQ15PqCZnAtLxE5qn6xTLFW/8e0ISHmEBERACgHFzRFEQAoBxc0RREAKAcXNEURACgHFzRFEQAoBxc0RpACyvs2/QufC0RJbU8ozOnpX6GzUvnShHW9JgARIgARIgARIgARIgARIoAoCvk/KVejWSgNfVgd+J77W5pZOml5WkWAJYgeOYAdJHhxbXasn6NhuoXMvuF8t1IO3JkBoLX+eajkqp059JKvcD1IeKwERkEJAcXMEEZBCQHFzBBGQQkBxcwQRkEJAcXMEEZBCQHFzBBGQQkBxW9/mfTJ72AYpczzgENslnz5h14Y8i7DJlktqkcM4ScUKSA6juaXlGiLrHcSbACFOzqgdRepXEm5dg3qVZKuPiPnfHSZAmAoi2K3P7yvdkxurgnWKiV4bl4wkOYxmPm+F2FD5CTmGaJelQv7ndG7NMbCZbW34n3FYpOWBzJXMKXAeMRtizqmVTMnmJEACJEACJEACJEACI0vgD1uqVK+gHgywAAAAAElFTkSuQmCC");
    }

    &--back {
      background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAo5JREFUeAHt219LFUEYx3FPdJGUfyrMCBEJMSSI7gRJlCAwCITAIPAiKPDCiy668CJfQi+hFxIUgiCIEkgQokhISET2B0Kt1Or0HXBgGJgzA92cc57fwsM8O7MezvPZdXV3Z1tatEhAAhKQgAQkIAEJSEACTSpQrVavEZ1NWt7/lQXMdeIr8VpIkSUg7sj5QvhFSN4IkavEjpcJWiGBMUh8ClDi9JWHNNciMUB8jEWC9e/kQ+ZgXMEU3k98CDDidJeOYas4lyl+OxYJ1vfIR6zi9FH8+wAjTvfpGLOK00vxW7FIsP6D/KZVnB6KfxdgxOlPOm5ZxblE8ZuxSLD+i/y2VZyLFL8eYMTpAR13rOJcoPi1WCRYPySfsIrTRfFvA4w4PaLjrlWc8xT/JhYJ1n+T37OKc5biVwOMOHU4963idFK8uwJPLX8YmLKK007xyykZ+v8SD6zitFH8UgbnkVWcM8AsZnCmreKcBmahBo4bmrGK00rx8xmcx1ZxTgHzMoPzxCSOKxqYZxmcWbM4x0CfawA9bVScE436xRvue+tXLLPLANJJOmPkTtT6M1+ApH8UC5B0qVGAVHKx+jD3OU09zjmpg1ghUovd2x1+zyOjG2YeI9WCdI7QLdcUkOsHqOSm/WStz2j6MZD02Ce3l0HqJvTgsBYUQO7R8waRWuw+evZwyJRMXhj325tsQdL0l9yeB6mX2CJSi90JVB4PmZIpeKN+e5MtSCWTOG+YxPFFg6RpwB4j1YJ0haibieR1d9O+UqlsgOdmte4kENvp70+M2enmKEq9zDJnRyFTKUjx61DPMz9ibxgk90LdN+IFcdKeQEHFwLgjqa1gU20iAQlIQAISkIAEJCABCdSFwD+zl7njFzoBgAAAAABJRU5ErkJggg==");
    }

    &--lock {
      background-image: url("data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjgiIGhlaWdodD0iMzMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPjxkZWZzPjxmaWx0ZXIgeD0iLTM3LjUlIiB5PSItMzAlIiB3aWR0aD0iMTc1JSIgaGVpZ2h0PSIxNjAlIiBmaWx0ZXJVbml0cz0ib2JqZWN0Qm91bmRpbmdCb3giIGlkPSJhIj48ZmVPZmZzZXQgaW49IlNvdXJjZUFscGhhIiByZXN1bHQ9InNoYWRvd09mZnNldE91dGVyMSIvPjxmZUdhdXNzaWFuQmx1ciBzdGREZXZpYXRpb249IjIiIGluPSJzaGFkb3dPZmZzZXRPdXRlcjEiIHJlc3VsdD0ic2hhZG93Qmx1ck91dGVyMSIvPjxmZUNvbG9yTWF0cml4IHZhbHVlcz0iMCAwIDAgMCAwIDAgMCAwIDAgMCAwIDAgMCAwIDAgMCAwIDAgMC41IDAiIGluPSJzaGFkb3dCbHVyT3V0ZXIxIi8+PC9maWx0ZXI+PHBhdGggZD0iTTE0IDdhNCA0IDAgMCAxIDQgNHYzaDJhMiAyIDAgMCAxIDIgMnY5YTIgMiAwIDAgMS0yIDJIOGEyIDIgMCAwIDEtMi0ydi05YTIgMiAwIDAgMSAyLTJoMnYtM2E0IDQgMCAwIDEgNC00em02IDguNEg4YS42LjYgMCAwIDAtLjU5Mi41MDNMNy40IDE2djlhLjYuNiAwIDAgMCAuNTAzLjU5Mkw4IDI1LjZoMTJhLjYuNiAwIDAgMCAuNTkyLS41MDNMMjAuNiAyNXYtOWEuNi42IDAgMCAwLS41MDMtLjU5MkwyMCAxNS40em0tNi03YTIuNiAyLjYgMCAwIDAtMi41OTUgMi40MzZMMTEuNCAxMXYyLjk3NGg1LjJWMTFhMi42IDIuNiAwIDAgMC0yLjQzNi0yLjU5NUwxNCA4LjR6IiBpZD0iYiIvPjwvZGVmcz48ZyBmaWxsLXJ1bGU9Im5vbnplcm8iIGZpbGw9Im5vbmUiPjx1c2UgZmlsbD0iIzAwMCIgZmlsdGVyPSJ1cmwoI2EpIiB4bGluazpocmVmPSIjYiIvPjx1c2UgZmlsbD0iI0ZGRiIgeGxpbms6aHJlZj0iI2IiLz48L2c+PC9zdmc+");
    }

    &--unlock {
      background-image: url("data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjgiIGhlaWdodD0iMzMiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPjxkZWZzPjxmaWx0ZXIgeD0iLTM3LjUlIiB5PSItMjguNiUiIHdpZHRoPSIxNzUlIiBoZWlnaHQ9IjE1Ny4xJSIgZmlsdGVyVW5pdHM9Im9iamVjdEJvdW5kaW5nQm94IiBpZD0iYSI+PGZlT2Zmc2V0IGluPSJTb3VyY2VBbHBoYSIgcmVzdWx0PSJzaGFkb3dPZmZzZXRPdXRlcjEiLz48ZmVHYXVzc2lhbkJsdXIgc3RkRGV2aWF0aW9uPSIyIiBpbj0ic2hhZG93T2Zmc2V0T3V0ZXIxIiByZXN1bHQ9InNoYWRvd0JsdXJPdXRlcjEiLz48ZmVDb2xvck1hdHJpeCB2YWx1ZXM9IjAgMCAwIDAgMCAwIDAgMCAwIDAgMCAwIDAgMCAwIDAgMCAwIDAuNSAwIiBpbj0ic2hhZG93Qmx1ck91dGVyMSIvPjwvZmlsdGVyPjxwYXRoIGQ9Ik0xNCA2YTQgNCAwIDAgMSAzLjk1NSAzLjRIMTYuNTNhMi42MDIgMi42MDIgMCAwIDAtMi4zNjYtMS45OTVMMTQgNy40YTIuNiAyLjYgMCAwIDAtMi41OTUgMi40MzZMMTEuNCAxMHYyLjE3NWgtLjAwMkwxMS4zOTcgMTQgMjAgMTRhMiAyIDAgMCAxIDIgMnY5YTIgMiAwIDAgMS0yIDJIOGEyIDIgMCAwIDEtMi0ydi05YTIgMiAwIDAgMSAyLTJsMS45OTktLjAwMUwxMCAxMGE0IDQgMCAwIDEgNC00em02IDkuNEg4YS42LjYgMCAwIDAtLjU5Mi41MDNMNy40IDE2djlhLjYuNiAwIDAgMCAuNTAzLjU5Mkw4IDI1LjZoMTJhLjYuNiAwIDAgMCAuNTkyLS41MDNMMjAuNiAyNXYtOWEuNi42IDAgMCAwLS41MDMtLjU5MkwyMCAxNS40eiIgaWQ9ImIiLz48L2RlZnM+PGcgZmlsbC1ydWxlPSJub256ZXJvIiBmaWxsPSJub25lIj48dXNlIGZpbGw9IiMwMDAiIGZpbHRlcj0idXJsKCNhKSIgeGxpbms6aHJlZj0iI2IiLz48dXNlIGZpbGw9IiNGRkYiIHhsaW5rOmhyZWY9IiNiIi8+PC9nPjwvc3ZnPg==")
    }
  }
}
</style>
