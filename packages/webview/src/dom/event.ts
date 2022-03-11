import { isTrue } from "../utils"
import { isNZothElement } from "./element"
import { NZothEventListener } from "./vnode"
import { pipeline } from "@nzoth/bridge"
import { SyncFlags } from "@nzoth/shared"
import { queuePostFlushCb } from "vue"

let queue: any[] = []

function sync() {
  pipeline.sync(queue, window.webViewId)
  queue = []
}

export function dispatchEvent(nodeId: number, event: any) {
  queue.push([SyncFlags.DISPATCH_EVENT, window.webViewId, nodeId, event])
  queuePostFlushCb(sync)
}

let singleTouch = -1

export function addTap(
  el: HTMLElement,
  listener: NZothEventListener = {},
  onTap: (ev: TouchEvent) => void
) {
  let isMoved = false

  const onStart = (ev: TouchEvent) => {
    isMoved = false
    const firstTouch = ev.changedTouches[0]
    if (singleTouch === -1 && firstTouch) {
      singleTouch = firstTouch.identifier
    }
  }

  const onMove = (ev: TouchEvent) => {
    isMoved = true
  }

  const onEnd = (ev: TouchEvent) => {
    const firstTouch = ev.changedTouches[0]
    if (firstTouch.identifier !== singleTouch) {
      isMoved = false
      return
    }
    
    singleTouch = -1
    let cancel = false
    if (isNZothElement(el)) {
      const props = el.__instance!.props
      const disabled = props.disabled as boolean
      const loading = props.loading as boolean
      cancel = disabled || loading
    } else {
      const disabled = el.getAttribute("disabled")
      const loading = el.getAttribute("loading")
      cancel = isTrue(disabled || loading)
    }

    if (cancel) {
      ev.stopPropagation()
      ev.preventDefault()
      isMoved = false
      return
    }

    if (!isMoved) {
      onTap(ev)
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

  const onCancel = (e: TouchEvent) => {
    isMoved = false
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

export function addClickEvent(
  nodeId: number,
  el: any,
  listener: NZothEventListener = {}
) {
  if (el.isAddClickEvent) {
    return
  }
  el.isAddClickEvent = true

  return addTap(el, listener, args => {
    dispatchEvent(nodeId, { type: "click", args: [] })
  })
}
