import JSBridge from "../bridge"

interface PageScrollToOptions {
  scrollTop?: number
  duration: number
  selector?: string
  offsetTop?: number
}

export function pageScrollTo(options: PageScrollToOptions) {
  const { scrollTop, selector, offsetTop, duration } = options
  let top = -1
  if (selector) {
    const el = document.querySelector(selector) as HTMLElement
    if (el) {
      top = el.offsetTop + el.offsetHeight + (offsetTop || 0)
    }
  } else if (scrollTop !== undefined) {
    top = scrollTop
  }
  if (top > -1) {
    JSBridge.invoke("pageScrollTo", { top, duration })
  }
  return Promise.resolve({})
}
