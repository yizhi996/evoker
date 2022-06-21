import { ComponentInternalInstance, callWithAsyncErrorHandling } from "vue"
import { hyphenate, isArray } from "@vue/shared"
import { NZothElement } from "../../dom/element"
import { NZothEvent, NZothEventListener } from "../../dom/eventTarget"

interface Invoker extends NZothEventListener {
  value: EventValue
  attached: number
}

type EventValue = Function | Function[]

// Async edge case fix requires storing an event listener's attach timestamp.
let _getNow: () => number = Date.now

// To avoid the overhead of repeatedly calling performance.now(), we cache
// and use the same timestamp for all event listeners attached in the same tick.
let cachedNow = 0
const p = Promise.resolve()
const reset = () => {
  cachedNow = 0
}
const getNow = () => cachedNow || (p.then(reset), (cachedNow = _getNow()))

export function addEventListener(
  el: NZothElement,
  event: string,
  handler: NZothEventListener,
  options?: EventListenerOptions,
  modifiers?: string[]
) {
  el.addEventListener(event, handler, options, modifiers)
}

export function removeEventListener(
  el: NZothElement,
  event: string,
  handler: NZothEventListener,
  options?: EventListenerOptions
) {
  el.removeEventListener(event, handler)
}

export function patchEvent(
  el: NZothElement & { _vei?: Record<string, Invoker | undefined> },
  rawName: string,
  prevValue: EventValue | null,
  nextValue: EventValue | null,
  instance: ComponentInternalInstance | null = null
) {
  // vei = vue event invokers
  const invokers = el._vei || (el._vei = {})
  const existingInvoker = invokers[rawName]
  if (nextValue && existingInvoker) {
    // patch
    existingInvoker.value = nextValue
  } else {
    let [name, options] = parseName(rawName)
    if (nextValue) {
      // add
      const invoker = (invokers[rawName] = createInvoker(nextValue, instance))
      const event = nextValue as EventValue & { modifiers?: string[] }
      addEventListener(el, name, invoker, options, event.modifiers)
    } else if (existingInvoker) {
      // remove
      removeEventListener(el, name, existingInvoker, options)
      invokers[rawName] = undefined
    }
  }
}

const optionsModifierRE = /(?:Once|Passive|Capture)$/

function parseName(name: string): [string, EventListenerOptions | undefined] {
  let options: EventListenerOptions | undefined
  if (optionsModifierRE.test(name)) {
    options = {}
    let m
    while ((m = name.match(optionsModifierRE))) {
      name = name.slice(0, name.length - m[0].length)
      ;(options as any)[m[0].toLowerCase()] = true
      options
    }
  }
  return [hyphenate(name.slice(2)), options]
}

function createInvoker(initialValue: EventValue, instance: ComponentInternalInstance | null) {
  const invoker: Invoker = (e: NZothEvent) => {
    // async edge case #6566: inner click event triggers patch, event handler
    // attached to outer element during patch, and triggered again. This
    // happens because browsers fire microtask ticks between event propagation.
    // the solution is simple: we save the timestamp when a handler is attached,
    // and the handler would only fire if the event passed to it was fired
    // AFTER it was attached.
    const timeStamp = e.timeStamp || _getNow()

    if (timeStamp >= invoker.attached - 1) {
      if (e.args) {
        // emit
        callWithAsyncErrorHandling(invoker.value, instance, 6, e.args)
      } else {
        callWithAsyncErrorHandling(patchStopImmediatePropagation(e, invoker.value), instance, 5, [
          e
        ])
      }
    }
  }
  invoker.value = initialValue
  invoker.attached = getNow()
  return invoker
}

function patchStopImmediatePropagation(e: NZothEvent, value: EventValue): EventValue {
  if (isArray(value)) {
    const originalStop = e.stopImmediatePropagation
    e.stopImmediatePropagation = () => {
      originalStop.call(e)
      ;(e as any)._stopped = true
    }
    return value.map(fn => (e: Event) => !(e as any)._stopped && fn(e))
  } else {
    return value
  }
}
