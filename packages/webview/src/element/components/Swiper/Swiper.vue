<template>
  <nz-swiper ref="containerRef">
    <div class="nz-swiper__wrapper">
      <div class="nz-swiper__slide">
        <div class="nz-swiper__slide__frame" :style="{ width: frameWidth, transform: transform }">
          <slot></slot>
        </div>
        <div v-if="showIndicators" class="nz-swiper__indicators">
          <i
            v-for="i of itemCount"
            class="nz-swiper__indicators__item"
            :style="i - 1 === currentIndex ? `opacity: 1;background-color: ${indicatorColor};` : ''"
          ></i>
        </div>
      </div>
    </div>
  </nz-swiper>
</template>

<script setup lang="ts">
import { onMounted, ref, watch, computed, getCurrentInstance, nextTick, onUnmounted } from "vue"
import { useChildren } from "../../use/useRelation"
import { SWIPE_KEY } from "./constant"
import { useTouch } from "../../use/useTouch"
import TWEEN from "@tweenjs/tween.js"
import { isString } from "@vue/shared"

const containerRef = ref<HTMLElement>()

const emit = defineEmits(["change"])

const props = withDefaults(defineProps<{
  autoplay?: number | string
  duration?: number | string
  initialSwipe?: number
  width?: number | string
  height?: number | string
  loop?: boolean
  showIndicators?: boolean
  touchable?: boolean
  stopPropagation?: boolean
  indicatorColor?: string
}>(), {
  duration: 500,
  initialSwipe: 0,
  width: "auto",
  height: "auto",
  loop: true,
  showIndicators: true,
  touchable: true,
  stopPropagation: true,
  indicatorColor: "#1989fa"
})

const instance = getCurrentInstance()!

const touch = useTouch()
const { children, linkChildren } = useChildren(instance, SWIPE_KEY)

linkChildren({})

const itemCount = computed(() => {
  return children.length
})

watch(() => [...children], () => {
  nextTick(() => {
    animateScrollTo(props.initialSwipe, TWEEN.Easing.Linear.None, 0)
  })
})

const currentIndex = ref(0)
const offset = ref(0)

const transform = computed(() => {
  return `translate(${-offset.value}px, 0px) translateZ(0px)`
})

const autoScrollDelay = computed(() => {
  const value = props.autoplay
  return isString(value) ? parseInt(value) : value
})

const autoScrollDuration = computed(() => {
  const value = props.duration
  return isString(value) ? parseInt(value) : value
})

watch(() => props.touchable, (touchable) => {
  if (touchable) {
    removeTouchEvent()
    addTouchEvent()
  } else {
    removeTouchEvent()
  }
})

watch(() => props.autoplay, () => {
  autoScroll()
})

onMounted(() => {
  nextTick(() => {
    if (props.touchable) {
      addTouchEvent()
    }
    autoScroll()
  })
})

onUnmounted(() => {
  removeTouchEvent()
})

let autoScrollTimer: ReturnType<typeof setTimeout>

const autoScroll = () => {
  clearTimeout(autoScrollTimer)
  if (props.autoplay) {
    autoScrollTimer = setTimeout(() => {
      animateScrollTo(currentIndex.value + 1, TWEEN.Easing.Quadratic.InOut, autoScrollDuration.value)
      autoScroll()
    }, autoScrollDelay.value)
  }
}

const addTouchEvent = () => {
  if (containerRef.value) {
    containerRef.value.addEventListener("touchstart", onTouchStart)
    containerRef.value.addEventListener("touchmove", onTouchMove)
    containerRef.value.addEventListener("touchend", onTouchEnd)
    containerRef.value.addEventListener("touchcancel", onTouchEnd)
    containerRef.value.addEventListener("resize", onResize)
  }
}

const removeTouchEvent = () => {
  if (containerRef.value) {
    containerRef.value.removeEventListener("touchstart", onTouchStart)
    containerRef.value.removeEventListener("touchmove", onTouchMove)
    containerRef.value.removeEventListener("touchend", onTouchEnd)
    containerRef.value.removeEventListener("touchcancel", onTouchEnd)
    containerRef.value.removeEventListener("resize", onResize)
  }
}

let rect: DOMRect | undefined

const onResize = () => {
  rect = containerRef.value && containerRef.value.getBoundingClientRect()
}

const frameWidth = computed(() => {
  onResize()
  if (rect) {
    return itemCount.value * rect.width + "px"
  }
  return "100%"
})

let touching = false
let touchStartTimestamp = 0

const onTouchStart = (event: TouchEvent) => {
  touchStartTimestamp = event.timeStamp
  touching = true
  touch.start(event)
  clearTimeout(autoScrollTimer)
}

const onTouchMove = (event: TouchEvent) => {
  touching = true
  touch.move(event)
  event.preventDefault()
  const currentLeft = currentIndex.value * rect!.width
  offset.value = currentLeft - touch.deltaX.value
}

const onTouchEnd = (event: TouchEvent) => {
  const duration = event.timeStamp - touchStartTimestamp
  const x = touch.deltaX.value
  const speed = x / duration

  touching = false
  touch.reset()

  let next = currentIndex.value
  if (Math.abs(speed) > 0.25 || Math.abs(x) > rect!.width * 0.5) {
    if (x > 0) {
      next -= 1
    } else if (x < 0) {
      next += 1
    }
  }
  animateScrollTo(next, TWEEN.Easing.Linear.None, 250)
  autoScroll()
}

let currentAnimation = 0

const animate = () => {
  currentAnimation = requestAnimationFrame(animate)
  TWEEN.update()
}

const animateScrollTo = (index: number, easing: any, duration: number) => {
  if (touching) {
    return
  }
  if (itemCount.value === 0) {
    return
  }

  if (index > itemCount.value - 1) {
    if (props.loop) {
      currentIndex.value = 0
    } else {
      currentIndex.value = itemCount.value - 1
    }
  } else if (index < 0) {
    currentIndex.value = 0
  } else {
    currentIndex.value = index
  }

  const target = currentIndex.value * rect!.width

  currentAnimation = requestAnimationFrame(animate)
  new TWEEN.Tween({ target: offset.value })
    .to({ target }, duration)
    .easing(easing)
    .onUpdate(({ target }) => {
      offset.value = target
    })
    .onComplete(() => {
      emit("change", currentIndex.value)
      cancelAnimationFrame(currentAnimation)
    })
    .start()
}

</script>

<style lang="less">
nz-swiper {
  display: block;
  height: 150px;
}

.nz-swiper {
  &__wrapper {
    width: 100%;
    height: 100%;
    overflow: hidden;
    position: relative;
    transform: translateZ(0);
  }

  &__slide {
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;

    &__frame {
      display: flex;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      will-change: transform;
    }
  }

  &__indicators {
    position: absolute;
    display: flex;
    left: 50%;
    bottom: 12px;
    transform: translate(-50%);

    &__item {
      width: 6px;
      height: 6px;
      border-radius: 100%;
      opacity: 0.3;
      background-color: #ebedf0;
      transition: opacity 0.2s, background-color 0.2s;
    }

    &__item:not(:last-child) {
      margin-right: 6px;
    }
  }
}
</style>
