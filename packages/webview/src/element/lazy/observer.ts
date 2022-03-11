import {
  ImageLoadState,
  ImageLoadResult,
  loadImage,
  imageLazyLoadInfos
} from "./loader"

export const supportIntersectionObserver = "IntersectionObserver" in window

const observer = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      const { target, isIntersecting } = entry
      if (isIntersecting) {
        const info = imageLazyLoadInfos.find(info => info.el === target)
        if (info) {
          if (info.state === ImageLoadState.completion) {
            removeIntersectionObserve(info.el)
            return
          }
          loadImage(info.src).then(result => {
            info.state = ImageLoadState.completion
            removeIntersectionObserve(info.el)
            info.callback(result)
          })
        }
      }
    })
  },
  {
    root: null,
    rootMargin: "0px",
    threshold: 0.01
  }
)

export function addIntersectionObserve(
  el: HTMLElement,
  src: string,
  callback: (result: ImageLoadResult) => void
) {
  removeIntersectionObserve(el)

  imageLazyLoadInfos.push({
    el,
    src,
    state: ImageLoadState.pending,
    attempt: 0,
    callback
  })
  observer.observe(el)
}

export function removeIntersectionObserve(el: HTMLElement) {
  const i = imageLazyLoadInfos.findIndex(info => info.el === el)
  if (i > -1) {
    imageLazyLoadInfos.splice(i, 1)
  }
  observer.unobserve(el)
}
