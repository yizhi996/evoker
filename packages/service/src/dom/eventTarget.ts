import { isEvokerNode } from "./node"

export class EvokerEvent {
  type: string
  target?: any
  args: any[] = []

  timeStamp = 0

  constructor(type: string) {
    this.type = type
  }

  stopImmediatePropagation() {}
}

export interface EvokerEventListener {
  (evt: EvokerEvent): void
}

interface EvokerEventListenerParams {
  listener: EvokerEventListener
  options?: EventListenerOptions
  modifiers?: string[]
}

export class EvokerEventTarget {
  listeners?: Record<string, EvokerEventListenerParams[]>

  addEventListener(
    type: string,
    listener: EvokerEventListener,
    options?: EventListenerOptions,
    modifiers?: string[]
  ) {
    const listeners =
      this.listeners ||
      ((this.listeners = Object.create(null)) as Record<string, EvokerEventListenerParams[]>)

    !(type in listeners) && (listeners[type] = [])

    listeners[type].push({ listener, options, modifiers })

    isEvokerNode(this) && this.page.onAddEventListener(this, type, options, modifiers)
  }

  removeEventListener(type: string, listener: EvokerEventListener): void {
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

  dispatchEvent(event: EvokerEvent) {
    if (this.listeners === undefined || !(event.type in this.listeners)) {
      return
    }
    const stack = this.listeners[event.type]
    for (let i = 0, l = stack.length; i < l; i++) {
      stack[i].listener.call(this, event)
    }
  }
}
