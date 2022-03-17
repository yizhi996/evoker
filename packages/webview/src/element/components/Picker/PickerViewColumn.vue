<template>
  <nz-picker-view-column>
    <div ref="groupRef" class="nz-picker-view-column__group">
      <div
        class="nz-picker-view-column__mask"
        :style="{ 'background-size': `100% ${indicatorTop}px` }"
      ></div>
      <div
        ref="indicatorRef"
        class="nz-picker-view-column__indicator"
        :class="indicatorClass"
        :style="indicatorStyle"
      ></div>
      <div
        ref="contentRef"
        class="nz-picker-view-column__content"
        :style="{ transform: `translate3d(0, ${translateY}px, 0)`, padding: `${indicatorTop}px 0px` }"
      ></div>
    </div>
  </nz-picker-view-column>
</template>

<script setup lang="ts">
import { ref, getCurrentInstance, onMounted, nextTick } from "vue"
import { useTouch } from "../../use/useTouch"
import { useParent, ParentProvide } from "../../use/useRelation"
import { PICKER_VIEW_KEY, PickerViewProvide } from "./define"
import TWEEN from "@tweenjs/tween.js"
import { vibrateShort, NZJSBridge } from "../../../bridge"
import { safeRangeValue } from "../../utils"

const instance = getCurrentInstance()!

const touch = useTouch()

const groupRef = ref<HTMLElement>()

const indicatorRef = ref<HTMLElement>()

const contentRef = ref<HTMLElement>()

const translateY = ref<number>(0)

let parent: ParentProvide<PickerViewProvide> | null = null

let startPositionY = 0
let offsetY = 0

let currentIndex = 0

onMounted(() => {
  addTouchEvent()

  setTimeout(() => {
    const { parent: _parent } = useParent(instance, PICKER_VIEW_KEY)
    parent = _parent
    if (!parent) {
      console.warn("picker-view-column 必须添加在 picker-view 内")
    }
  })
})

const addTouchEvent = () => {
  groupRef.value?.addEventListener("touchstart", onTouchStart)
  groupRef.value?.addEventListener("touchmove", onTouchMove)
  groupRef.value?.addEventListener("touchend", onTouchEnd)
  groupRef.value?.addEventListener("touchcancel", onTouchEnd)
}

const getIndex = (y: number) => {
  return safeRangeValue(Math.round(-y / itemHeight), 0, totalCount - 1)
}

const momentumTimeThreshold = 300
const momentumYThreshold = 15
let momentumOffsetY = 0
let startTime = 0
let prevIndex = 0

const onTouchStart = (ev: TouchEvent) => {
  touch.start(ev)
  startPositionY = offsetY
  startTime = Date.now()
  momentumOffsetY = offsetY

  cancelAnimationFrame(currentAnimation)
  currentTween && currentTween.stop()

  parent && parent.onPickStart()
}

const onTouchMove = (ev: TouchEvent) => {
  ev.preventDefault()

  cancelAnimationFrame(currentAnimation)
  currentTween && currentTween.stop()

  touch.move(ev)
  let y = touch.deltaY.value + startPositionY
  if (y > 0) {
    y = y * 0.5
  }

  const index = getIndex(y)
  index !== prevIndex && playSound()

  translateY.value = y
  offsetY = y
  prevIndex = index
  currentIndex = index

  const now = Date.now()
  if (now - startTime > momentumTimeThreshold) {
    momentumOffsetY = y
    startTime = now
  }
}

const onTouchEnd = (ev: TouchEvent) => {
  let distance = offsetY - momentumOffsetY
  const duration = Date.now() - startTime
  if (duration < momentumTimeThreshold && Math.abs(distance) > momentumYThreshold) {
    const speed = Math.abs(distance / duration)
    distance = offsetY + (speed / 0.003) * (distance < 0 ? -1 : 1)
    const index = getIndex(distance)
    animationTranslate(-index * itemHeight, 1000, true)
  } else if (offsetY > 0) {
    animationTranslate(0, 200, true)
  } else if (Math.abs(offsetY) > maxY) {
    animationTranslate(-maxY, 200, true)
  } else {
    const index = getIndex(offsetY)
    animationTranslate(-index * itemHeight, 200, true)
  }
  touch.reset()

  parent && parent.onPickEnd()
}

let currentAnimation = 0
let currentTween: any

const animate = () => {
  currentAnimation = requestAnimationFrame(animate)
  TWEEN.update()
}

const animationTranslate = (y: number, duration: number, animation: boolean) => {

  cancelAnimationFrame(currentAnimation)
  currentTween && currentTween.stop()

  if (animation) {
    const temp = { y: offsetY }
    currentAnimation = requestAnimationFrame(animate)
    currentTween = new TWEEN.Tween(temp)
      .to({ y }, duration)
      .easing(TWEEN.Easing.Cubic.Out)
      .onUpdate(({ y }) => {
        translateY.value = y
        offsetY = y
        const index = getIndex(offsetY)
        index !== prevIndex && playSound()
        prevIndex = index
        currentIndex = index
      })
      .onComplete(() => {
        cancelAnimationFrame(currentAnimation)
        prevIndex = getIndex(offsetY)
        currentIndex = prevIndex
        parent && parent.onChange()
      })
      .start()
  } else {
    translateY.value = y
    offsetY = y
    prevIndex = getIndex(offsetY)
    currentIndex = prevIndex
  }
}

const playSound = () => {
  vibrateShort({ type: "light" })
  NZJSBridge.invoke("playSystemSound", { id: 1157 })
}

const indicatorTop = ref(0)
let totalCount = 0
let itemHeight = 0
let maxY = 0

const setHeight = (height: number) => {
  nextTick(() => {
    itemHeight = indicatorRef.value!.offsetHeight
    totalCount = contentRef.value!.children.length
    for (let i = 0; i < totalCount; i++) {
      const child = contentRef.value!.children.item(i) as HTMLElement
      child.style.height = itemHeight + "px"
      child.style.overflow = "hidden"
    }
    indicatorTop.value = (height - itemHeight) * 0.5
    indicatorRef.value!.style.top = indicatorTop.value + "px"
    maxY = itemHeight * (totalCount - 1)
  })
}

const indicatorStyle = ref<string>()

const setIndicatorStyle = (style: string) => {
  indicatorStyle.value = style
}

const indicatorClass = ref<string>()

const setIndicatorClass = (cls: string) => {
  indicatorClass.value = cls
}

const maskStyle = ref<string>()

const setMaskStyle = (style: string) => {
  maskStyle.value = style
}

const maskClass = ref<string>()

const setMaskClass = (cls: string) => {
  maskClass.value = cls
}

const setValue = (value: number) => {
  nextTick(() => {
    const index = value ? safeRangeValue(value, 0, totalCount - 1) : 0
    prevIndex = index
    currentIndex = index
    animationTranslate(-index * itemHeight, 0, false)
  })
}

const getCurrent = () => {
  return currentIndex
}

defineExpose({
  setIndicatorStyle,
  setIndicatorClass,
  setMaskStyle,
  setMaskClass,
  setHeight,
  setValue,
  getCurrent
})

</script>

<style lang="less">
nz-picker-view-column {
  flex: 1;
  position: relative;
  overflow: hidden;
  height: 100%;
  z-index: 0;
}

.nz-picker-view-column {
  &__group {
    height: 100%;
  }

  &__mask {
    background: linear-gradient(
        180deg,
        hsla(0, 0%, 100%, 0.95),
        hsla(0, 0%, 100%, 0.6)
      ),
      linear-gradient(0deg, hsla(0, 0%, 100%, 0.95), hsla(0, 0%, 100%, 0.6));
    background-position: top, bottom;
    background-repeat: no-repeat;
    background-size: 100% 102px;
    height: 100%;
    margin: 0 auto;
    top: 0;
    transform: translateZ(0);
  }

  &__indicator {
    top: 102px;
    height: 34px;

    &::before {
      border-top: 1px solid #e5e5e5;
      top: 0;
      transform: scaleY(0.5);
      transform-origin: 0 0;
    }

    &::after {
      border-bottom: 1px solid #e5e5e5;
      bottom: 0;
      transform: scaleY(0.5);
      transform-origin: 0 100%;
    }

    &::before,
    &::after {
      color: #e5e5e5;
      content: " ";
      height: 1px;
      left: 0;
      position: absolute;
      right: 0;
    }
  }

  &__mask,
  &__indicator {
    left: 0;
    pointer-events: none;
    position: absolute;
    width: 100%;
    z-index: 3;
  }

  &__content {
    left: 0;
    position: absolute;
    top: 0;
    width: 100%;
    will-change: transform;

    padding: 102px 0px;
    transform: translateY(0px) translateZ(0px);
  }
}
</style>