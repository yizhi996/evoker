<template>
  <nz-scroll-view>
    <div
      class="nz-scroll-view__wrapper"
      :class="scrollX ? 'nz-scroll-view__wrapper--horizontal' : 'nz-scroll-view__wrapper--vertical'"
    >
      <div
        ref="tongcengRef"
        class="nz-scroll-view__wrapper"
        :id="tongcengKey"
        :style="scrollX ? 'overflow: auto hidden' : 'overflow: hidden auto;'"
      >
        <div
          id="content"
          :style="{ height: scrollX ? '' : '100%', display: enableFlex ? 'flex' : '' }"
        >
          <slot></slot>
        </div>
      </div>
    </div>
  </nz-scroll-view>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, watch, getCurrentInstance, nextTick, watchEffect } from "vue"
import { unitToPx } from "../utils/format"
import useJSAnimation from "../use/useJSAnimation"
import { Easing } from "@tweenjs/tween.js"
import useNative from "../use/useNative"
import { NZJSBridge } from "../../bridge"

const instance = getCurrentInstance()!

const emit = defineEmits([
  "scrolltoupper",
  "scrolltolower",
  "scroll",
  "dragstart",
  "dragging",
  "dragend"
])

const props = withDefaults(
  defineProps<{
    scrollX?: boolean
    scrollY?: boolean
    scrollTop?: number | string
    scrollLeft?: number | string
    scrollIntoView?: string
    upperThreshold?: number | string
    lowerThreshold?: number | string
    scrollWithAnimation?: boolean
    enableFlex?: boolean
    enhanced?: boolean
    bounces?: boolean
    showScrollbar?: boolean
    pagingEnabled?: boolean
    fastDeceleration?: boolean
  }>(),
  {
    scrollX: false,
    scrollY: false,
    scrollTop: 0,
    scrollLeft: 0,
    upperThreshold: 50,
    lowerThreshold: 50,
    scrollWithAnimation: false,
    enableFlex: false,
    enhanced: false,
    bounces: true,
    showScrollbar: true,
    pagingEnabled: false,
    fastDeceleration: false
  }
)

const {
  tongcengKey,
  nativeId: scrollViewId,
  tongcengRef,
  insertContainer
} = useNative({ scrollEnabled: true })

let lastScrollTime = 0
let lastScrollTop = 0
let lastScrollLeft = 0

watch(
  () => props.scrollTop,
  scrollTop => {
    const target = unitToPx(scrollTop)
    if (target === lastScrollTop) {
      return
    }
    props.scrollY && scrollTo(target, Axis.VETRICAL)
  }
)

watch(
  () => props.scrollLeft,
  scrollLeft => {
    const target = unitToPx(scrollLeft)
    if (target === lastScrollLeft) {
      return
    }
    props.scrollX && scrollTo(target, Axis.HORIZONTAL)
  }
)

watch(
  () => props.scrollIntoView,
  scrollIntoView => {
    if (scrollIntoView && /^[_a-zA-Z][-_a-zA-Z0-9:]*$/.test(scrollIntoView)) {
      const view = tongcengRef.value && tongcengRef.value.querySelector("#" + scrollIntoView)
      view && scrollToElement(view)
    }
  }
)

const onTouchStart = (ev: TouchEvent) => {
  const el = ev.target as HTMLElement
  emit("dragstart", { scrollTop: el.scrollTop, scrollLeft: el.scrollLeft })
}

const onTouchMove = (ev: TouchEvent) => {
  const el = ev.target as HTMLElement
  emit("dragging", { scrollTop: el.scrollTop, scrollLeft: el.scrollLeft })
}

const onTouchEnd = (ev: TouchEvent) => {
  const el = ev.target as HTMLElement
  emit("dragend", { scrollTop: el.scrollTop, scrollLeft: el.scrollLeft })
}

const addDragEvent = () => {
  const el = tongcengRef.value!
  el.addEventListener("touchstart", onTouchStart)
  el.addEventListener("touchmove", onTouchMove)
  el.addEventListener("touchend", onTouchEnd)
  el.addEventListener("touchcancel", onTouchEnd)
}

const removeDragEvent = () => {
  const el = tongcengRef.value!
  el.removeEventListener("touchstart", onTouchStart)
  el.removeEventListener("touchmove", onTouchMove)
  el.removeEventListener("touchend", onTouchEnd)
  el.removeEventListener("touchcancel", onTouchEnd)
}

watch(
  () => props.enhanced,
  enhanced => {
    nextTick(() => {
      if (enhanced) {
        addDragEvent()
      } else {
        removeDragEvent()
      }
    })
  },
  { immediate: true }
)

onMounted(() => {
  if (tongcengRef.value) {
    tongcengRef.value.addEventListener("scroll", onScroll)
    if (props.enhanced) {
      setTimeout(() => {
        insertContainer(success => {
          if (success) {
            operateScrollView()
          }
        })
      })
    }
  }
})

onUnmounted(() => {
  if (tongcengRef.value) {
    tongcengRef.value.removeEventListener("scroll", onScroll)
  }
})

watchEffect(() => {
  NZJSBridge.invoke("operateScrollView", {
    parentId: tongcengKey,
    scrollViewId,
    bounces: props.bounces,
    showScrollbar: props.showScrollbar,
    pagingEnabled: props.pagingEnabled,
    fastDeceleration: props.fastDeceleration
  })
})

const operateScrollView = () => {
  if (props.enhanced) {
    NZJSBridge.invoke("operateScrollView", {
      parentId: tongcengKey,
      scrollViewId,
      bounces: props.bounces,
      showScrollbar: props.showScrollbar,
      pagingEnabled: props.pagingEnabled,
      fastDeceleration: props.fastDeceleration
    })
  }
}

const enum Directions {
  LEFT = "left",
  RIGHT = "right",
  TOP = "top",
  BOTTOM = "bottom"
}

const onScroll = (ev: Event) => {
  ev.preventDefault()
  ev.stopPropagation()

  if (ev.target && ev.timeStamp - lastScrollTime > 20) {
    lastScrollTime = ev.timeStamp
    const target = ev.target as HTMLElement

    instance.props.scrollTop = target.scrollTop
    instance.props.scrollLeft = target.scrollLeft
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
          direction: Directions.LEFT
        })
      } else if (
        x < 0 &&
        target.scrollLeft + target.offsetWidth + lowerThreshold >= target.scrollWidth
      ) {
        emit("scrolltolower", {
          direction: Directions.RIGHT
        })
      }
    }

    if (props.scrollY) {
      const y = lastScrollTop - target.scrollTop
      if (y > 0 && target.scrollTop <= upperThreshold) {
        emit("scrolltoupper", {
          direction: Directions.TOP
        })
      } else if (
        y < 0 &&
        target.scrollTop + target.offsetHeight + lowerThreshold >= target.scrollHeight
      ) {
        emit("scrolltolower", {
          direction: Directions.BOTTOM
        })
      }
    }

    lastScrollLeft = target.scrollLeft
    lastScrollTop = target.scrollTop
  }
}

const scrollToElement = (el: Element) => {
  const mainRect = tongcengRef.value!.getBoundingClientRect()
  const elRect = el.getBoundingClientRect()
  if (props.scrollX) {
    const offsetX = elRect.left - mainRect.left
    const target = tongcengRef.value!.scrollLeft + offsetX
    scrollTo(target, Axis.HORIZONTAL)
  }
  if (props.scrollY) {
    const offsetY = elRect.top - mainRect.top
    const target = tongcengRef.value!.scrollTop + offsetY
    scrollTo(target, Axis.VETRICAL)
  }
}

const { startAnimation, stopAnimation } = useJSAnimation<{ target: number }>()

const enum Axis {
  HORIZONTAL,
  VETRICAL
}

const scrollTo = (target: number, axis: Axis) => {
  const el = tongcengRef.value!
  function update(target: number) {
    if (axis === Axis.HORIZONTAL) {
      el.scrollLeft = target
    } else if (axis === Axis.VETRICAL) {
      el.scrollTop = target
    }
  }
  stopAnimation()
  if (props.scrollWithAnimation) {
    let current = 0
    if (axis === Axis.HORIZONTAL) {
      current = el.scrollLeft
    } else if (axis === Axis.VETRICAL) {
      current = el.scrollTop
    }
    startAnimation({
      begin: { target: current },
      end: { target },
      duration: 500,
      easing: Easing.Quadratic.InOut,
      onUpdate: ({ target }) => {
        update(target)
      }
    })
  } else {
    update(target)
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
