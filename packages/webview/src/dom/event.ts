import { isNZothElement } from "./element"
import { NZothEventListenerOptions } from "./vnode"
import { sync } from "@nzoth/bridge"
import { SyncFlags } from "@nzoth/shared"

interface Event {
  type: string
  args: any
}

export function dispatchEvent(nodeId: number, event: string | Event) {
  const message = [SyncFlags.DISPATCH_EVENT, window.webViewId, nodeId, event]
  sync(message, window.webViewId)
}

let singleTouch = -1

export const enum TouchEventType {
  START = "touchstart",
  MOVE = "touchmove",
  END = "touchend",
  CANCEL = "touchcancel"
}

export const touchEvents = [
  "touchstart",
  "touchmove",
  "touchend",
  "touchcancel"
]

export const tapEvents = ["click", "longpress"]

export function addTouchEvent(
  nodeId: number,
  el: any,
  type: string,
  options: NZothEventListenerOptions
) {
  const listenerOptions: Record<string, NZothEventListenerOptions> =
    el.__listenerOptions || (el.__listenerOptions = {})

  listenerOptions[type] = options

  el.addEventListener(
    type,
    (ev: TouchEvent) => {
      const listener = listenerOptions[type]
      if (listener && listener.modifiers) {
        if (listener.modifiers.includes("stop")) {
          ev.stopPropagation()
        }
        if (listener.modifiers.includes("prevent")) {
          ev.preventDefault()
        }
      }

      const event = createCustomTouchEvent(el, ev, type)
      dispatchEvent(nodeId, { type, args: [event] })
    },
    {
      capture: false,
      passive: true
    }
  )
}

export function addClickEvent(
  el: any,
  onClick?: (ev: TouchEvent, isLongPress: boolean) => void
) {
  const listenerOptions: Record<string, NZothEventListenerOptions> =
    el.__listenerOptions || (el.__listenerOptions = {})

  let touchStartTimestamp = 0
  let isTouching = false
  let isMoved = false

  const isDisabled = () => {
    let result = false
    if (isNZothElement(el)) {
      const { disabled, loading } = el.__instance.props as {
        disabled: boolean
        loading: boolean
      }
      result = disabled || loading
    }
    return result
  }

  const onStart = (ev: TouchEvent) => {
    isTouching = true
    touchStartTimestamp = ev.timeStamp

    if (isDisabled()) {
      ev.stopPropagation()
      ev.preventDefault()
      isTouching = false
      isMoved = false
      return
    }

    const firstTouch = ev.changedTouches[0]
    if (singleTouch === -1 && firstTouch) {
      singleTouch = firstTouch.identifier
    }
  }

  const onMove = (ev: TouchEvent) => {
    isMoved = true
  }

  const onEnd = (ev: TouchEvent) => {
    isTouching = false
    const firstTouch = ev.changedTouches[0]
    if (firstTouch.identifier !== singleTouch) {
      isMoved = false
      return
    }

    if (isDisabled()) {
      ev.stopPropagation()
      ev.preventDefault()
      isMoved = false
      return
    }

    singleTouch = -1

    if (!isMoved) {
      const isLongPress = ev.timeStamp - touchStartTimestamp > 350
      onClick && onClick(ev, isLongPress)

      const listener = isLongPress
        ? listenerOptions["longpress"]
        : listenerOptions["click"]
      if (listener.modifiers) {
        if (listener.modifiers.includes("stop")) {
          ev.stopPropagation()
        }
        if (listener.modifiers.includes("prevent")) {
          ev.preventDefault()
        }
      }
    }
    isMoved = false
  }

  const onCancel = (ev: TouchEvent) => {
    isMoved = false
    isTouching = false
    singleTouch = -1
  }

  el.addEventListener("touchstart", onStart, {
    capture: false,
    passive: true
  })

  el.addEventListener("touchmove", onMove, {
    capture: false,
    passive: true
  })

  el.addEventListener("touchend", onEnd, {
    capture: false,
    passive: true
  })

  el.addEventListener("touchcancel", onCancel, {
    capture: false,
    passive: true
  })

  const remove = () => {
    el.removeEventListener("touchstart", onStart)
    el.removeEventListener("touchmove", onMove)
    el.removeEventListener("touchend", onEnd)
    el.removeEventListener("touchcancel", onCancel)
  }

  return remove
}

export function addTapEvent(
  nodeId: number,
  el: any,
  type: string,
  options: NZothEventListenerOptions
) {
  const listenerOptions: Record<string, NZothEventListenerOptions> =
    el.__listenerOptions || (el.__listenerOptions = {})
  listenerOptions[type] = options

  if (el.__touchEvent) {
    return el.__touchEvent as () => void
  }

  el.__touchEvent = addClickEvent(el, (ev, isLongPress) => {
    const type =
      listenerOptions["longpress"] && isLongPress ? "longpress" : "click"
    const event = createCustomTouchEvent(el, ev, type)
    dispatchEvent(nodeId, { type, args: [event] })
  })
  return el.__touchEvent as () => void
}

function createCustomTouchEvent(
  currentTarget: HTMLElement,
  ev: TouchEvent,
  type: string
) {
  const target = ev.target as HTMLElement

  const changedTouches: NZTouch[] = []
  for (let i = 0; i < ev.changedTouches.length; i++) {
    const touch = ev.changedTouches.item(i)!
    changedTouches.push({
      identifier: touch.identifier,
      force: touch.force,
      clientX: touch.clientX,
      clientY: touch.clientY,
      pageX: touch.pageX,
      pageY: touch.pageY
    })
  }

  const touch = ev.changedTouches.item(0)!

  const event: NZTouchEvent & NZCustomEvent = {
    type: type,
    timestamp: ev.timeStamp,
    target: {
      id: target.id,
      offsetLeft: target.offsetLeft,
      offsetTop: target.offsetTop
    },
    currentTarget: {
      id: currentTarget.id,
      offsetLeft: currentTarget.offsetLeft,
      offsetTop: currentTarget.offsetTop
    },
    touches: changedTouches,
    changedTouches,
    detail: {
      x: touch.pageX,
      y: touch.pageY
    }
  }
  return event
}

export function createCustomEvent(
  currentTarget: HTMLElement,
  type: string,
  detail: Record<string, any>
) {
  const target = {
    id: currentTarget.id,
    offsetLeft: currentTarget.offsetLeft,
    offsetTop: currentTarget.offsetTop
  }
  const event: NZCustomEvent = {
    type: type,
    timestamp: Date.now(),
    target,
    currentTarget: target,
    detail
  }
  return event
}

interface NZEventTarget {
  id: string
  offsetLeft: number
  offsetTop: number
}

interface NZTouch {
  identifier: number
  clientX: number
  clientY: number
  force: number
  pageX: number
  pageY: number
}

interface NZBaseEvent {
  type: string
  timestamp: number
  target: NZEventTarget
  currentTarget: NZEventTarget
}

interface NZTouchEvent extends NZBaseEvent {
  touches: NZTouch[]
  changedTouches: NZTouch[]
}

interface NZCustomEvent extends NZBaseEvent {
  detail: Record<string, any>
}
