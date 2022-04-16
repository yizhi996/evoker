import { getCurrentWebViewId } from "../../../app"
import { randomId } from "../../../utils"
import { extend, SyncFlags } from "@nzoth/shared"
import { sync } from "@nzoth/bridge"

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

    const message = [
      SyncFlags.ADD_INTERSECTION_OBSERVER,
      this.observerId,
      targetSelector,
      this.options,
      this.relativeInfo
    ]
    sync(message, this.pageId)

    observers.set(this.observerId, callback)
  }

  disconnect() {
    this.connected = false
    if (this.observerId) {
      observers.delete(this.observerId)

      const message = [SyncFlags.REMOVE_INTERSECTION_OBSERVER, this.observerId]
      sync(message, this.pageId)

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
  extend(defaultOptions, options)
  return new IntersectionObserver(defaultOptions)
}

export function intersectionObserverEntry(data: any[]) {
  const [_, observerId, entry] = data
  const callback = observers.get(observerId)
  if (callback) {
    callback(entry)
  }
}
