let lastTouchAt = 0
let isMoved = false

window.addEventListener(
  "touchstart",
  () => {
    isMoved = false
  },
  {
    capture: true,
    passive: true
  }
)

window.addEventListener(
  "touchmove",
  () => {
    isMoved = true
  },
  {
    capture: true,
    passive: true
  }
)

window.addEventListener(
  "touchend",
  (event: TouchEvent) => {
    const now = Date.now()
    const delta = now - lastTouchAt
    if (delta < 500) {
      event.preventDefault()
    }
    if (isMoved) {
      lastTouchAt = 0
    } else {
      lastTouchAt = now
    }
  },
  true
)

window.addEventListener(
  "touchcancel",
  () => {
    isMoved = false
  },
  true
)
