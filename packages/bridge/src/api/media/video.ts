import { openNativelyCameraRecordVideo } from "./camera"
import { openNativelyAlbumChooseVideo } from "./album"
import { showActionSheet } from "../ui/interaction"
import {
  invokeSuccess,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  wrapperAsyncAPI
} from "../../async"
import { clamp, extend } from "@nzoth/shared"

const enum Events {
  CHOOSE_VIDEO = "chooseVideo"
}

interface ChooseVideoOptions {
  sourceType?: Array<"album" | "camera">
  compressed?: boolean
  maxDuration?: number
  camera?: Array<"back" | "front">
  success?: ChooseVideoSuccessCallback
  fail?: ChooseVideoFailCallback
  complete?: ChooseVideoCompleteCallback
}

interface ChooseVideoSuccessCallbackResult {
  tempFilePath: string
  duration: number
  size: number
  width: number
  height: number
}

type ChooseVideoSuccessCallback = (res: ChooseVideoSuccessCallbackResult) => void

type ChooseVideoFailCallback = (res: GeneralCallbackResult) => void

type ChooseVideoCompleteCallback = (res: GeneralCallbackResult) => void

export function chooseVideo<T extends ChooseVideoOptions = ChooseVideoOptions>(
  options: T
): AsyncReturn<T, ChooseVideoOptions> {
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = extend(
      {
        sourceType: ["album", "camera"],
        compressed: true,
        maxDuration: 60,
        camera: ["back", "front"]
      },
      options
    )
    finalOptions.maxDuration = clamp(finalOptions.maxDuration, 1, 60)

    const haveCamera = finalOptions.sourceType!.includes("camera")
    const haveAlbum = finalOptions.sourceType!.includes("album")

    const event = Events.CHOOSE_VIDEO

    const sizeType: Array<"compressed" | "original"> = finalOptions.compressed
      ? ["compressed"]
      : ["original"]

    const openCamera = () => {
      const device = finalOptions.camera.includes("front") ? "front" : "back"
      openNativelyCameraRecordVideo(sizeType, finalOptions.maxDuration, device)
        .then(result => {
          invokeSuccess(event, finalOptions, result)
        })
        .catch(error => {
          invokeFailure(event, finalOptions, error)
        })
    }

    const openAlbum = () => {
      openNativelyAlbumChooseVideo(sizeType)
        .then(result => {
          invokeSuccess(event, finalOptions, result)
        })
        .catch(error => {
          invokeFailure(event, finalOptions, error)
        })
    }

    if (haveCamera && !haveAlbum) {
      openCamera()
      return
    }

    if (haveAlbum && !haveCamera) {
      openAlbum()
      return
    }

    showActionSheet({ itemList: ["拍摄", "从手机相册选择"] })
      .then(result => {
        const tapIndex = result.tapIndex
        if (tapIndex === 0) {
          openCamera()
        } else if (tapIndex === 1) {
          openAlbum()
        }
      })
      .catch(error => {
        invokeFailure(event, finalOptions, error)
      })
  }, options)
}
