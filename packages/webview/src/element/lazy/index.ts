import { ImageLoadResult } from "./loader"
import { addEventObserve, removeEventObserve } from "./event"
import {
  addIntersectionObserve,
  removeIntersectionObserve,
  supportIntersectionObserver
} from "./observer"

export { loadImage } from "./loader"

export type { ImageLoadResult }

export function addObserve(
  el: HTMLElement,
  src: string,
  callback: (result: ImageLoadResult) => void
) {
  if (supportIntersectionObserver) {
    addIntersectionObserve(el, src, callback)
  } else {
    addEventObserve(el, src, callback)
  }
}

export function removeObserve(el: HTMLElement) {
  if (supportIntersectionObserver) {
    removeIntersectionObserve(el)
  } else {
    removeEventObserve(el)
  }
}
