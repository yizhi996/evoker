import { NZJSBridge } from "../bridge"
import "intersection-observer"

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

NZJSBridge.subscribe<{
  observerId: string
  targetSelector: string
  options: CreateIntersectionObserverOptions
  relativeInfo: RelativeInfo
}>("addIntersectionObserver", message => {
  const { observerId, targetSelector, options, relativeInfo } = message

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
        const {
          target,
          intersectionRatio,
          intersectionRect,
          boundingClientRect,
          rootBounds,
          time,
          isIntersecting
        } = entry
        NZJSBridge.publish(
          "intersectionObserverEntry",
          {
            observerId,
            entry: {
              id: target.id,
              isIntersecting,
              intersectionRatio,
              intersectionRect,
              boundingClientRect,
              relativeRect: rootBounds,
              time
            }
          },
          window.webViewId
        )
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
})

NZJSBridge.subscribe<{
  observerId: string
}>("removeIntersectionObserver", message => {
  const { observerId } = message
  const observer = observers.get(observerId)
  if (observer) {
    observer.disconnect()
    observers.delete(observerId)
  }
})
