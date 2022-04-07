import { isNZothNode } from "./node"

export class NZothEvent {
  type: string
  target?: any
  args: any[] = []

  timeStamp = 0

  constructor(type: string) {
    this.type = type
  }

  stopImmediatePropagation() {}
}

export interface NZothEventListener {
  (evt: NZothEvent): void
}

interface NZothEventListenerParams {
  listener: NZothEventListener
  options?: EventListenerOptions
  modifiers?: string[]
}

export class NZothEventTarget {
  listeners?: Record<string, NZothEventListenerParams[]>

  addEventListener(
    type: string,
    listener: NZothEventListener,
    options?: EventListenerOptions,
    modifiers?: string[]
  ) {
    const listeners =
      this.listeners ||
      ((this.listeners = Object.create(null)) as Record<
        string,
        NZothEventListenerParams[]
      >)

    !(type in listeners) && (listeners[type] = [])

    listeners[type].push({ listener, options, modifiers })

    isNZothNode(this) &&
      this.page.onAddEventListener(this, type, options, modifiers)
  }

  removeEventListener(type: string, listener: NZothEventListener): void {
    if (this.listeners === undefined || !(type in this.listeners)) {
      return
    }
    const stack = this.listeners[type]
    for (let i = 0, l = stack.length; i < l; i++) {
      if (stack[i].listener === listener) {
        stack.splice(i, 1)
        return this.removeEventListener(type, listener)
      }
    }
  }

  dispatchEvent(event: NZothEvent) {
    if (this.listeners === undefined || !(event.type in this.listeners)) {
      return
    }
    const stack = this.listeners[event.type]
    for (let i = 0, l = stack.length; i < l; i++) {
      stack[i].listener.call(this, event)
    }
  }
}
