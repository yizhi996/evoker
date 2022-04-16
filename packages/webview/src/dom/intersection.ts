import { NZJSBridge } from "../bridge"
import "intersection-observer"
import { SyncFlags } from "@nzoth/shared"
import { sync } from "@nzoth/bridge"

interface CreateIntersectionObserverOptions {
  thresholds: number[]
  initialRatio: number
  observeAll: boolean
}

interface RelativeInfo {
  selector?: string
  margins?: Margin
}

interface Margin {
  left: number
  right: number
  top: number
  bottom: number
}

function marginToString(margin?: Margin) {
  if (margin) {
    const top = margin.top ?? 0
    const right = margin.right ?? 0
    const bottom = margin.bottom ?? 0
    const left = margin.left ?? 0
    return `${top}px ${right}px ${bottom}px ${left}px`
  }
  return "0px"
}

const observers = new Map<string, IntersectionObserver>()

export function addIntersectionObserver(data: any[]) {
  const [_, observerId, targetSelector, options, relativeInfo] = data as [
    SyncFlags,
    string,
    string,
    CreateIntersectionObserverOptions,
    RelativeInfo
  ]

  let observer = observers.get(observerId)
  if (observer) {
    observer.disconnect()
    observers.delete(observerId)
  }

  let root: Element | null = null
  if (relativeInfo.selector) {
    root = document.querySelector(relativeInfo.selector)
  }

  observer = new IntersectionObserver(
    entries => {
      entries.forEach(entry => {
        const message = [
          SyncFlags.INTERSECTION_OBSERVER_ENTRY,
          observerId,
          {
            id: entry.target.id,
            isIntersecting: entry.isIntersecting,
            intersectionRatio: entry.intersectionRatio,
            intersectionRect: entry.intersectionRect,
            boundingClientRect: entry.boundingClientRect,
            relativeRect: entry.rootBounds,
            time: entry.time
          }
        ]
        sync(message, window.webViewId)
      })
    },
    {
      root,
      rootMargin: marginToString(relativeInfo.margins),
      threshold: options.thresholds
    }
  )

  if (options.observeAll) {
    document.querySelectorAll(targetSelector).forEach(el => {
      observer!.observe(el)
    })
  } else {
    const el = document.querySelector(targetSelector)
    el && observer.observe(el)
  }
}

export function removeIntersectionObserver(data: any[]) {
  const [_, observerId] = data as [SyncFlags, string]
  const observer = observers.get(observerId)
  if (observer) {
    observer.disconnect()
    observers.delete(observerId)
  }
}
