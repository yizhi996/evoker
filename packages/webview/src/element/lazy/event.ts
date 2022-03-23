import {
  ImageLoadState,
  ImageLoadResult,
  loadImage,
  imageLazyLoadInfos
} from "./loader"
import { supportIntersectionObserver } from "./observer"
import throttle from "lodash.throttle"

if (!supportIntersectionObserver) {
  document.addEventListener("scroll", throttle(onScroll, 100))
}

function onScroll() {
  const needLoadImageInfos = imageLazyLoadInfos.filter(
    info => info.state === ImageLoadState.PENDING && checkInView(info.el)
  )

  needLoadImageInfos.forEach(info => {
    loadImage(info.src).then(result => {
      removeEventObserve(info.el)
      info.callback(result)
    })
  })
}

export function addEventObserve(
  el: HTMLElement,
  src: string,
  callback: (result: ImageLoadResult) => void
) {
  removeEventObserve(el)

  if (checkInView(el)) {
    loadImage(src).then(result => {
      removeEventObserve(el)
      callback(result)
    })
  } else {
    imageLazyLoadInfos.push({
      el,
      src,
      state: ImageLoadState.PENDING,
      attempt: 0,
      callback
    })
  }
}

export function removeEventObserve(el: HTMLElement) {
  const i = imageLazyLoadInfos.findIndex(info => info.el === el)
  if (i > -1) {
    imageLazyLoadInfos.splice(i, 1)
  }
}

export function checkInView(el: HTMLElement) {
  const rect = el.getBoundingClientRect()
  return (
    rect.top < window.innerHeight &&
    rect.left < window.innerWidth &&
    rect.right > 0
  )
}
