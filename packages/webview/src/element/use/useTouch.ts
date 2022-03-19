// copy from vant-ui
import { ref } from "vue"

const MIN_DISTANCE = 10

type Direction = "" | "vertical" | "horizontal"

function getDirection(x: number, y: number) {
  if (x > y && x > MIN_DISTANCE) {
    return "horizontal"
  }
  if (y > x && y > MIN_DISTANCE) {
    return "vertical"
  }
  return ""
}

export type Touch = ReturnType<typeof Touch>

function Touch() {
  const startX = ref(0)
  const startY = ref(0)
  const deltaX = ref(0)
  const deltaY = ref(0)
  const offsetX = ref(0)
  const offsetY = ref(0)
  const direction = ref<Direction>("")

  const isVertical = () => direction.value === "vertical"
  const isHorizontal = () => direction.value === "horizontal"

  const reset = () => {
    deltaX.value = 0
    deltaY.value = 0
    offsetX.value = 0
    offsetY.value = 0
    direction.value = ""
  }

  const start = ((event: TouchEvent) => {
    reset()
    startX.value = event.touches[0].clientX
    startY.value = event.touches[0].clientY
  }) as EventListener

  const move = ((event: TouchEvent) => {
    const touch = event.touches[0]
    // Fix: Safari back will set clientX to negative number
    deltaX.value = touch.clientX < 0 ? 0 : touch.clientX - startX.value
    deltaY.value = touch.clientY - startY.value
    offsetX.value = Math.abs(deltaX.value)
    offsetY.value = Math.abs(deltaY.value)

    if (!direction.value) {
      direction.value = getDirection(offsetX.value, offsetY.value)
    }
  }) as EventListener

  return {
    move,
    start,
    reset,
    startX,
    startY,
    deltaX,
    deltaY,
    offsetX,
    offsetY,
    direction,
    isVertical,
    isHorizontal
  }
}

export default function useTouch(el: HTMLElement) {
  const touch = Touch()

  let touchStartCallback: (ev: TouchEvent, touch: Touch) => void

  let touchMoveCallback: (ev: TouchEvent, touch: Touch) => void

  let touchEndCallback: (ev: TouchEvent, touch: Touch) => void

  const onTouchStart = (ev: TouchEvent) => {
    touch.start(ev)
    touchStartCallback && touchStartCallback(ev, touch)
  }

  const onTouchMove = (ev: TouchEvent) => {
    touch.move(ev)
    touchMoveCallback && touchMoveCallback(ev, touch)
  }

  const onTouchEnd = (ev: TouchEvent) => {
    touchEndCallback && touchEndCallback(ev, touch)
    touch.reset()
  }

  const addEventListener = () => {
    el.addEventListener("touchstart", onTouchStart)
    el.addEventListener("touchmove", onTouchMove)
    el.addEventListener("touchend", onTouchEnd)
    el.addEventListener("touchcancel", onTouchEnd)
  }

  const removeEventListener = () => {
    el.removeEventListener("touchstart", onTouchStart)
    el.removeEventListener("touchmove", onTouchMove)
    el.removeEventListener("touchend", onTouchEnd)
    el.removeEventListener("touchcancel", onTouchEnd)
  }

  addEventListener()

  return {
    addEventListener,
    removeEventListener,
    onTouchStart: (hook: typeof touchStartCallback) => {
      touchStartCallback = hook
    },
    onTouchMove: (hook: typeof touchMoveCallback) => {
      touchMoveCallback = hook
    },
    onTouchEnd: (hook: typeof touchEndCallback) => {
      touchEndCallback = hook
    }
  }
}
