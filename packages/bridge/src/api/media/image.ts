import { openNativelyCameraTakePhoto, TempFile } from "./camera"
import { openNativelyAlbumChoosePhoto } from "./album"
import { showActionSheet } from "../ui/interaction"
import { invoke } from "../../bridge"
import {
  invokeSuccess,
  invokeFailure,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { extend } from "@nzoth/shared"
import { requestAuthorization } from "../auth"
import { ErrorCodes, errorMessage } from "../../errors"

const enum Events {
  PREVIEW_IMAGE = "previewImage",
  CHOOSE_IMAGE = "chooseImage",
  SAVE_IMAGE_TO_PHOTOS_ALBUM = "saveImageToPhotosAlbum",
  GET_IMAGE_INFO = "getImageInfo"
}

interface PreviewImageOptions {
  urls: string[]
  current: string
  success?: PreviewImageSuccessCallback
  fail?: PreviewImageFailCallback
  complete?: PreviewImageCompleteCallback
}

type PreviewImageSuccessCallback = (res: GeneralCallbackResult) => void

type PreviewImageFailCallback = (res: GeneralCallbackResult) => void

type PreviewImageCompleteCallback = (res: GeneralCallbackResult) => void

export function previewImage<T extends PreviewImageOptions = PreviewImageOptions>(
  options: T
): AsyncReturn<T, PreviewImageOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.PREVIEW_IMAGE
    if (!options.urls || options.urls.length === 0) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "urls"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface ChooseImageOptions {
  count?: number
  sizeType?: Array<"original" | "compressed">
  sourceType?: Array<"album" | "camera">
  success?: ChooseImageSuccessCallback
  fail?: ChooseImageFailCallback
  complete?: ChooseImageCompleteCallback
}

interface ChooseImageSuccessCallbackResult {
  tempFilePaths: string[]
  tempFiles: TempFile[]
}

type ChooseImageSuccessCallback = (res: ChooseImageSuccessCallbackResult) => void

type ChooseImageFailCallback = (res: GeneralCallbackResult) => void

type ChooseImageCompleteCallback = (res: GeneralCallbackResult) => void

export function chooseImage<T extends ChooseImageOptions = ChooseImageOptions>(
  options: T
): AsyncReturn<T, ChooseImageOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.CHOOSE_IMAGE
    const finalOptions = extend(
      {
        count: 9,
        sizeType: ["original", "compressed"],
        sourceType: ["album", "camera"]
      },
      options
    )

    const haveCamera = finalOptions.sourceType!.includes("camera")
    const haveAlbum = finalOptions.sourceType!.includes("album")

    const openCamera = () => {
      openNativelyCameraTakePhoto(finalOptions.sizeType!)
        .then(result => {
          invokeSuccess(event, finalOptions, {
            tempFilePaths: [result.tempFilePath],
            tempFiles: [result.tempFile]
          })
        })
        .catch(error => {
          invokeFailure(event, finalOptions, error)
        })
    }

    const openAlbum = () => {
      openNativelyAlbumChoosePhoto({
        count: finalOptions.count!,
        sizeType: finalOptions.sizeType!
      })
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

    showActionSheet({ itemList: ["拍照", "从手机相册选择"] })
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

interface SaveImageToPhotosAlbumOptions {
  filePath: string
  success?: SaveImageToPhotosAlbumSuccessCallback
  fail?: SaveImageToPhotosAlbumFailCallback
  complete?: SaveImageToPhotosAlbumCompleteCallback
}

type SaveImageToPhotosAlbumSuccessCallback = (res: GeneralCallbackResult) => void

type SaveImageToPhotosAlbumFailCallback = (res: GeneralCallbackResult) => void

type SaveImageToPhotosAlbumCompleteCallback = (res: GeneralCallbackResult) => void

export function saveImageToPhotosAlbum<
  T extends SaveImageToPhotosAlbumOptions = SaveImageToPhotosAlbumOptions
>(options: T): AsyncReturn<T, SaveImageToPhotosAlbumOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.SAVE_IMAGE_TO_PHOTOS_ALBUM

    if (!options.filePath) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "filePath"))
      return
    }

    const scope = "scope.writePhotosAlbum"
    requestAuthorization(scope)
      .then(() => {
        invoke<SuccessResult<T>>(event, options, result => {
          invokeCallback(event, options, result)
        })
      })
      .catch(error => {
        invokeFailure(event, options, error)
      })
  }, options)
}

interface GetImageInfoOptions {
  src: string
  success?: GetImageInfoSuccessCallback
  fail?: GetImageInfoFailCallback
  complete?: GetImageInfoCompleteCallback
}

interface GetImageInfoSuccessCallbackResult {
  width: number
  height: number
  path: string
  orientation:
    | "up"
    | "up-mirrored"
    | "down"
    | "down-mirrored"
    | "right"
    | "right-mirrored"
    | "left"
    | "left-mirrored"
  type: "unknown" | "jpeg" | "png" | "gif" | "tiff"
}

type GetImageInfoSuccessCallback = (res: GetImageInfoSuccessCallbackResult) => void

type GetImageInfoFailCallback = (res: GeneralCallbackResult) => void

type GetImageInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getImageInfo<T extends GetImageInfoOptions = GetImageInfoOptions>(
  options: T
): AsyncReturn<T, GetImageInfoOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.GET_IMAGE_INFO
    if (!options.src) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "src"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
