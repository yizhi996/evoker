<template>
  <nz-movable-view
    ref="movableRef"
    style="transform-origin: center;"
    :style="{ 'will-change': isTouching ? 'transform' : 'auto', transform: transform }"
  ></nz-movable-view>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted, getCurrentInstance } from "vue"
import { extend } from "@vue/shared"
import { useTouch } from "../../use/useTouch"
import { useParent } from "../../use/useRelation"
import { MOVABLE_KEY } from "./constant"
import { unitToPx } from "../../utils/format"
import TWEEN from "@tweenjs/tween.js"

const emit = defineEmits(["update:x", "update:y", "change", "scale"])

const props = withDefaults(defineProps<{
  direction?: "all" | "vertical" | "horizontal" | "none",
  inertia?: boolean,
  outOfBounds?: boolean,
  x?: number | string
  y?: number | string
  damping?: number,
  friction?: number,
  disabled?: boolean,
  scale?: boolean,
  scaleMin?: number,
  scaleMax?: number,
  scaleValue?: number,
  animation?: boolean
}
>(), {
  direction: "none",
  damping: 20,
  friction: 2,
  scaleMin: 0.5,
  scaleMax: 10,
  scaleValue: 1,
  animation: true
})

const instance = getCurrentInstance()!
const touch = useTouch()

const movableRef = ref<HTMLElement>()
const size = reactive({ width: 0, height: 0 })
const areaRect = reactive({ x: 0, y: 0, left: 0, right: 0, top: 0, bottom: 0, width: 0, height: 0 })
const transform = ref("translateX(0px) translateY(0px) translateZ(0px) scale(1)")

const offset = { x: 0, y: 0 }
const startOffset = { x: 0, y: 0 }
let isTouching = false
let isMounted = false

watch(() => [props.x, props.y], () => {
  if (isTouching) {
    return
  }
  const x = unitToPx(props.x || 0)
  const y = unitToPx(props.y || 0)
  if (x !== offset.x || y !== offset.y) {
    if (isMounted) {
      onMoveWithPropsChange(x, y, true)
    }
  }
})

onMounted(() => {
  addTouchEvent()

  setTimeout(() => {
    const { parent } = useParent(instance, MOVABLE_KEY)
    if (!parent) {
      console.warn("MovableView 必须添加在 MovableArea 内")
    }
  })
})

const addTouchEvent = () => {
  movableRef.value?.addEventListener("touchstart", onTouchStart)
  movableRef.value?.addEventListener("touchmove", onTouchMove)
  movableRef.value?.addEventListener("touchend", onTouchEnd)
  movableRef.value?.addEventListener("touchcancel", onTouchEnd)
}

const onTouchStart = (event: TouchEvent) => {
  touch.start(event)
  isTouching = true
  startOffset.x = offset.x
  startOffset.y = offset.y
}

const onTouchMove = (event: TouchEvent) => {
  touch.move(event)
  event.preventDefault()

  isTouching = true

  let x = 0
  if (props.direction !== "vertical") {
    x = startOffset.x + touch.deltaX.value - areaRect.left + areaRect.left
    const maxX = areaRect.width - size.width
    if (x < 0) {
      x = 0
    } else if (x > maxX) {
      x = maxX
    }
  }

  let y = 0
  if (props.direction !== "horizontal") {
    y = startOffset.y + touch.deltaY.value - areaRect.top + areaRect.top
    const maxY = areaRect.height - size.height
    if (y < 0) {
      y = 0
    } else if (y > maxY) {
      y = maxY
    }
  }


  offset.x = x
  offset.y = y

  transform.value = `translateX(${x}px) translateY(${y}px) translateZ(0px) scale(${1})`

  emitChange(x, y)
}

const onTouchEnd = (event: TouchEvent) => {
  emitChange(offset.x, offset.y)
  touch.reset()
  isTouching = false
}

const onMoveWithPropsChange = (x: number, y: number, animation: boolean) => {
  let sfaeX = x
  if (props.direction !== "vertical") {
    const maxX = areaRect.width - size.width
    if (sfaeX < 0) {
      sfaeX = 0
    } else if (sfaeX > maxX) {
      sfaeX = maxX
    }
  }

  let safeY = y
  if (props.direction !== "horizontal") {
    const maxY = areaRect.height - size.height
    if (safeY < 0) {
      safeY = 0
    } else if (safeY > maxY) {
      safeY = maxY
    }
  }

  onMove(sfaeX, safeY, animation)
}

let currentAnimation = 0
let currentTween: any

const animate = () => {
  currentAnimation = requestAnimationFrame(animate)
  TWEEN.update()
}

const onMove = (x: number, y: number, animation: boolean) => {
  const scale = 1

  cancelAnimationFrame(currentAnimation)
  currentTween && currentTween.stop()

  if (animation && props.animation) {
    const position = { x: offset.x, y: offset.y }
    currentAnimation = requestAnimationFrame(animate)
    currentTween = new TWEEN.Tween(position)
      .to({ x, y }, 1000)
      .easing(TWEEN.Easing.Quartic.Out)
      .onUpdate(({ x, y }) => {
        offset.x = x
        offset.y = y
        transform.value = `translateX(${x}px) translateY(${y}px) translateZ(0px) scale(${scale})`
      })
      .onComplete(() => {
        cancelAnimationFrame(currentAnimation)
        emitChange(position.x, position.y)
      })
      .start()
  } else {
    transform.value = `translateX(${x}px) translateY(${y}px) translateZ(0px) scale(${scale})`
    offset.x = x
    offset.y = y
    emitChange(x, y)
  }
}

const emitChange = (x: number, y: number) => {
  if (props.x !== x) {
    instance.props.x = x
    emit("update:x", x)
  }

  if (props.y !== y) {
    instance.props.y = y
    emit("update:y", y)
  }

  emit("change", { x, y })
}

const setAreaRect = (rect: DOMRect) => {
  areaRect.x = rect.x
  areaRect.y = rect.y
  areaRect.left = rect.left
  areaRect.right = rect.right
  areaRect.top = rect.top
  areaRect.bottom = rect.bottom
  areaRect.width = rect.width
  areaRect.height = rect.height

  const viewRect = movableRef.value!.getBoundingClientRect()
  size.width = viewRect.width
  size.height = viewRect.height

  const x = unitToPx(props.x || 0)
  const y = unitToPx(props.y || 0)
  onMoveWithPropsChange(x, y, false)

  isMounted = true
}

extend(instance.proxy, { setAreaRect })

</script>

<style>
nz-movable-view {
  display: inline-block;
  position: absolute;
  width: 10px;
  height: 10px;
  top: 0;
  left: 0;
}
</style>
