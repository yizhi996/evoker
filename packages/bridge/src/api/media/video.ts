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
import { clamp } from "@nzoth/shared"

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
  return wrapperAsyncAPI(
    options => {
      options.maxDuration = clamp(options.maxDuration, 1, 60)

      const haveCamera = options.sourceType.includes("camera")
      const haveAlbum = options.sourceType.includes("album")

      const event = Events.CHOOSE_VIDEO

      const sizeType: Array<"compressed" | "original"> = options.compressed
        ? ["compressed"]
        : ["original"]

      const openCamera = () => {
        const device = options.camera.includes("front") ? "front" : "back"
        openNativelyCameraRecordVideo(sizeType, options.maxDuration, device)
          .then(result => {
            invokeSuccess(event, options, result)
          })
          .catch(error => {
            invokeFailure(event, options, error)
          })
      }

      const openAlbum = () => {
        openNativelyAlbumChooseVideo(sizeType)
          .then(result => {
            invokeSuccess(event, options, result)
          })
          .catch(error => {
            invokeFailure(event, options, error)
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
          invokeFailure(event, options, error)
        })
    },
    options,
    {
      sourceType: ["album", "camera"],
      compressed: true,
      maxDuration: 60,
      camera: ["back", "front"]
    }
  )
}
