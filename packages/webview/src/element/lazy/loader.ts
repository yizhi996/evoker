import { NZJSBridge } from "../../bridge"

export interface ImageLoadResult {
  src: string
  width: number
  height: number
}

export const enum ImageLoadState {
  pending = 0,
  completion,
  failed
}

export interface ImageLazyLoadInfo {
  el: HTMLElement
  src: string
  state: ImageLoadState
  attempt: number
  callback: (result: ImageLoadResult) => void
}

export const imageLazyLoadInfos: ImageLazyLoadInfo[] = []

export function loadImage(src: string): Promise<ImageLoadResult> {
  return new Promise((resolve, reject) => {
    if (!src) {
      const err = new Error("load image src is required")
      return reject(err)
    }

    const image = new Image()

    image.onload = () => {
      resolve({
        src: image.src,
        width: image.naturalWidth,
        height: image.naturalHeight
      })
    }

    image.onerror = e => reject(e)

    if (/^webp/.test(src)) {
      image.src = src
    } else if (/^https?:\/\//.test(src)) {
      image.src = src
    } else if (/^\s*data:image\//.test(src)) {
      image.src = src
    } else {
      NZJSBridge.invoke<{ src: string }>(
        "getLocalImage",
        { path: src },
        result => {
          if (result.errMsg) {
            reject(result.errMsg)
          } else {
            image.src = result.data!.src
          }
        }
      )
    }
  })
}
