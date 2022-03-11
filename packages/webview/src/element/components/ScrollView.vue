<template>
  <nz-scroll-view>
    <div
      ref="warpRef"
      class="nz-scroll-view__wrapper"
      :class="scrollX ? 'nz-scroll-view__wrapper--horizontal' : 'nz-scroll-view__wrapper--vertical'"
    >
      <div
        ref="mainRef"
        class="nz-scroll-view__wrapper"
        :style="scrollX ? 'overflow: auto hidden; padding-bottom: 20px;' : 'overflow: hidden auto;'"
      >
        <div id="content" :style="scrollX ? '' : 'height: 100%;'">
          <slot></slot>
        </div>
      </div>
    </div>
  </nz-scroll-view>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch, getCurrentInstance } from "vue"
import { unitToPx } from "../utils/format"
import TWEEN from "@tweenjs/tween.js"

const instance = getCurrentInstance()!

const emit = defineEmits(["scrolltoupper", "scrolltolower", "scroll"])

const props = withDefaults(defineProps<{
  scrollX?: boolean
  scrollY?: boolean
  scrollTop?: number | string
  scrollLeft?: number | string
  scrollIntoView?: string
  upperThreshold?: number | string
  lowerThreshold?: number | string
  scrollWithAnimation?: boolean
}>(), {
  scrollX: false,
  scrollY: false,
  scrollTop: 0,
  scrollLeft: 0,
  upperThreshold: 50,
  lowerThreshold: 50,
  scrollWithAnimation: false
})

const warpRef = ref<HTMLElement>()
const mainRef = ref<HTMLElement>()

let lastScrollTime = 0
let lastScrollTop = 0
let lastScrollLeft = 0

let currentAnimation = 0

watch(() => props.scrollTop, (scrollTop) => {
  const target = unitToPx(scrollTop)
  if (target === lastScrollTop) {
    return
  }
  props.scrollY && scrollTo(target, "y")
})

watch(() => props.scrollLeft, (scrollLeft) => {
  const target = unitToPx(scrollLeft)
  if (target === lastScrollLeft) {
    return
  }
  props.scrollX && scrollTo(target, "x")
})

watch(() => props.scrollIntoView, (scrollIntoView) => {
  if (scrollIntoView && /^[_a-zA-Z][-_a-zA-Z0-9:]*$/.test(scrollIntoView)) {
    const view = mainRef.value && mainRef.value.querySelector("#" + scrollIntoView)
    if (view) {
      scrollToElement(view)
    }
  }
})

onMounted(() => {
  if (mainRef.value) {
    mainRef.value.addEventListener('scroll', onScroll)
  }
})

onUnmounted(() => {
  if (mainRef.value) {
    mainRef.value.removeEventListener('scroll', onScroll)
  }
})

const onScroll = (ev: Event) => {
  ev.preventDefault()
  ev.stopPropagation()

  if (ev.target && ev.timeStamp - lastScrollTime > 20) {
    lastScrollTime = ev.timeStamp
    const target = ev.target as HTMLElement

    instance.props.scrollTop = target.scrollTop
    emit("scroll", {
      scrollLeft: target.scrollLeft,
      scrollTop: target.scrollTop,
      scrollHeight: target.scrollHeight,
      scrollWidth: target.scrollWidth,
      deltaX: lastScrollLeft - target.scrollLeft,
      deltaY: lastScrollTop - target.scrollTop
    })

    const lowerThreshold = unitToPx(props.lowerThreshold)
    const upperThreshold = unitToPx(props.upperThreshold)

    if (props.scrollX) {
      const x = lastScrollLeft - target.scrollLeft
      if (x > 0 && target.scrollLeft <= upperThreshold) {
        emit("scrolltoupper", {
          direction: "left"
        })
      } else if (x < 0 && target.scrollLeft + target.offsetWidth + lowerThreshold >= target.scrollWidth) {
        emit("scrolltolower", {
          direction: "right"
        })
      }
    }

    if (props.scrollY) {
      const y = lastScrollTop - target.scrollTop
      if (y > 0 && target.scrollTop <= upperThreshold) {
        emit("scrolltoupper", {
          direction: "top"
        })
      } else if (y < 0 && target.scrollTop + target.offsetHeight + lowerThreshold >= target.scrollHeight) {
        emit("scrolltolower", {
          direction: "bottom"
        })
      }
    }

    lastScrollLeft = target.scrollLeft
    lastScrollTop = target.scrollTop
  }
}

const scrollToElement = (el: Element) => {
  const mainRect = mainRef.value!.getBoundingClientRect()
  const elRect = el.getBoundingClientRect()
  if (props.scrollX) {
    const offsetX = elRect.left - mainRect.left
    const target = mainRef.value!.scrollLeft + offsetX
    scrollTo(target, "x")
  }
  if (props.scrollY) {
    const offsetY = elRect.top - mainRect.top
    const target = mainRef.value!.scrollTop + offsetY
    scrollTo(target, "y")
  }
}

const animate = () => {
  currentAnimation = requestAnimationFrame(animate)
  TWEEN.update()
}

const scrollTo = (target: number, direction: string) => {
  function invoke(target: number) {
    if (direction === "x") {
      mainRef.value!.scrollLeft = target
    } else {
      mainRef.value!.scrollTop = target
    }
  }
  if (props.scrollWithAnimation) {
    currentAnimation = requestAnimationFrame(animate)
    const current = direction === "x" ? mainRef.value!.scrollLeft : mainRef.value!.scrollTop
    new TWEEN.Tween({ target: current })
      .to({ target }, 500)
      .easing(TWEEN.Easing.Quadratic.InOut)
      .onUpdate(({ target }) => {
        invoke(target)
      })
      .onComplete(() => {
        cancelAnimationFrame(currentAnimation)
      })
      .start()
  } else {
    invoke(target)
  }
}


</script>

<style lang="less">
nz-scroll-view {
  display: block;
  width: 100%;
}

.nz-scroll-view__wrapper {
  position: relative;
  width: 100%;
  height: 100%;
  max-height: inherit;
  -webkit-overflow-scrolling: touch;

  &--vertical {
    overflow-x: hidden;
  }

  &--horizontal {
    overflow-y: hidden;
  }
}
</style>
