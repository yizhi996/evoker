import { InnerJSBridge } from "../../bridge"
import { getCurrentWebViewId } from "../../../app"
import { randomId } from "../../../utils"

type ObserverCallback = (result: ObserverCallbackResult) => void

interface ObserverCallbackResult {
  id: string
  dataset: Record<string, any>
  isIntersecting: boolean
  intersectionRatio: number
  intersectionRect: Rect
  boundingClientRect: Rect
  relativeRect: Rect
  time: number
}

interface Rect {
  left: number
  right: number
  top: number
  bottom: number
  width: number
  height: number
}

interface Margin {
  left: number
  right: number
  top: number
  bottom: number
}

interface RelativeInfo {
  selector?: string
  margins?: Margin
}

const observers = new Map<string, ObserverCallback>()

class IntersectionObserver {
  private pageId: number

  private observerId?: string

  private connected = false

  private options: CreateIntersectionObserverOptions

  private relativeInfo?: RelativeInfo

  constructor(options: CreateIntersectionObserverOptions) {
    this.options = options

    this.pageId = getCurrentWebViewId()
  }

  relativeTo(selector: string, margins?: Margin): IntersectionObserver {
    this.relativeInfo = { selector, margins }
    return this
  }

  relativeToViewport(margins?: Margin): IntersectionObserver {
    this.relativeInfo = { margins }
    return this
  }

  observe(targetSelector: string, callback: ObserverCallback) {
    if (this.connected) {
      console.error("必须 disconnect 后才能再次 observe")
      return
    }
    this.observerId = randomId()
    this.connected = true
    InnerJSBridge.publish(
      "addIntersectionObserver",
      {
        observerId: this.observerId,
        targetSelector,
        options: this.options,
        relativeInfo: this.relativeInfo
      },
      this.pageId
    )
    observers.set(this.observerId, callback)
  }

  disconnect() {
    this.connected = false
    if (this.observerId) {
      observers.delete(this.observerId)
      InnerJSBridge.publish(
        "removeIntersectionObserver",
        {
          observerId: this.observerId
        },
        this.pageId
      )
      this.observerId = undefined
    }
  }
}

interface CreateIntersectionObserverOptions {
  thresholds?: number[]
  initialRatio?: number
  observeAll?: boolean
}

export function createIntersectionObserver(
  options?: CreateIntersectionObserverOptions
): IntersectionObserver {
  const defaultOptions: CreateIntersectionObserverOptions = {
    thresholds: [0],
    initialRatio: 0,
    observeAll: false
  }
  Object.assign(defaultOptions, options)
  return new IntersectionObserver(defaultOptions)
}

InnerJSBridge.subscribe<{ observerId: string; entry: ObserverCallbackResult }>(
  "intersectionObserverEntry",
  result => {
    const { observerId, entry } = result
    const callback = observers.get(observerId)
    if (callback) {
      callback(entry)
    }
  }
)
