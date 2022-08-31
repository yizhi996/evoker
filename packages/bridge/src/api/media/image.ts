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
import { requestAuthorization } from "../auth"
import { ErrorCodes, errorMessage } from "../../errors"

const enum Events {
  PREVIEW_IMAGE = "previewImage",
  CHOOSE_IMAGE = "chooseImage",
  SAVE_IMAGE_TO_PHOTOS_ALBUM = "saveImageToPhotosAlbum",
  GET_IMAGE_INFO = "getImageInfo",
  COMPRESS_IMAGE = "compressImage"
}

interface PreviewImageOptions {
  /** 需要预览的图片链接列表 */
  urls: string[]
  /** 当前显示图片的链接 */
  current: string
  /** 接口调用成功的回调函数 */
  success?: PreviewImageSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: PreviewImageFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: PreviewImageCompleteCallback
}

type PreviewImageSuccessCallback = (res: GeneralCallbackResult) => void

type PreviewImageFailCallback = (res: GeneralCallbackResult) => void

type PreviewImageCompleteCallback = (res: GeneralCallbackResult) => void

/** 在新页面中全屏预览图片 */
export function previewImage<T extends PreviewImageOptions = PreviewImageOptions>(
  options: T
): AsyncReturn<T, PreviewImageOptions> {
  return wrapperAsyncAPI(options => {
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
  /** 最多可以选择的图片张数 */
  count?: number
  /** 所选的图片的尺寸
   *
   * 可选值：
   * - original: 原图
   * - compressed: 压缩图
   */
  sizeType?: Array<"original" | "compressed">
  /** 选择图片的来源
   *
   * 可选值：
   * - album: 从相册选图
   * - camera: 使用相机
   */
  sourceType?: Array<"album" | "camera">
  /** 接口调用成功的回调函数 */
  success?: ChooseImageSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ChooseImageFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ChooseImageCompleteCallback
}

interface ChooseImageSuccessCallbackResult {
  /** 图片的本地临时文件路径列表 (本地路径) */
  tempFilePaths: string[]
  /** 图片的本地临时文件列表 */
  tempFiles: TempFile[]
}

type ChooseImageSuccessCallback = (res: ChooseImageSuccessCallbackResult) => void

type ChooseImageFailCallback = (res: GeneralCallbackResult) => void

type ChooseImageCompleteCallback = (res: GeneralCallbackResult) => void

/** 从本地相册选择图片或使用相机拍照 */
export function chooseImage<T extends ChooseImageOptions = ChooseImageOptions>(
  options: T
): AsyncReturn<T, ChooseImageOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.CHOOSE_IMAGE

      const haveCamera = options.sourceType.includes("camera")
      const haveAlbum = options.sourceType.includes("album")

      const openCamera = () => {
        openNativelyCameraTakePhoto(options.sizeType!)
          .then(result => {
            invokeSuccess(event, options, {
              tempFilePaths: [result.tempFilePath],
              tempFiles: [result.tempFile]
            })
          })
          .catch(error => {
            invokeFailure(event, options, error)
          })
      }

      const openAlbum = () => {
        openNativelyAlbumChoosePhoto({
          count: options.count,
          sizeType: options.sizeType
        })
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
          invokeFailure(event, options, error)
        })
    },
    options,
    {
      count: 9,
      sizeType: ["original", "compressed"],
      sourceType: ["album", "camera"]
    }
  )
}

interface SaveImageToPhotosAlbumOptions {
  /** 图片文件路径，可以是临时文件路径或永久文件路径 (本地路径)，不支持网络路径 */
  filePath: string
  /** 接口调用成功的回调函数 */
  success?: SaveImageToPhotosAlbumSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SaveImageToPhotosAlbumFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SaveImageToPhotosAlbumCompleteCallback
}

type SaveImageToPhotosAlbumSuccessCallback = (res: GeneralCallbackResult) => void

type SaveImageToPhotosAlbumFailCallback = (res: GeneralCallbackResult) => void

type SaveImageToPhotosAlbumCompleteCallback = (res: GeneralCallbackResult) => void

/** 保存图片到系统相册
 *
 * 需要用户授权 `scope.writePhotosAlbum`
 */
export function saveImageToPhotosAlbum<
  T extends SaveImageToPhotosAlbumOptions = SaveImageToPhotosAlbumOptions
>(options: T): AsyncReturn<T, SaveImageToPhotosAlbumOptions> {
  return wrapperAsyncAPI(options => {
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
  /** 图片的路径，支持网络路径、本地路径、代码包路径 */
  src: string
  /** 接口调用成功的回调函数 */
  success?: GetImageInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetImageInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetImageInfoCompleteCallback
}

interface GetImageInfoSuccessCallbackResult {
  /** 图片原始宽度，单位px */
  width: number
  /** 图片原始高度，单位px */
  height: number
  /** 图片的本地路径 */
  path: string
  /** 拍照时设备方向 */
  orientation:
    | "up"
    | "up-mirrored"
    | "down"
    | "down-mirrored"
    | "right"
    | "right-mirrored"
    | "left"
    | "left-mirrored"
  /** 图片格式 */
  type: "unknown" | "jpeg" | "png" | "gif" | "tiff"
}

type GetImageInfoSuccessCallback = (res: GetImageInfoSuccessCallbackResult) => void

type GetImageInfoFailCallback = (res: GeneralCallbackResult) => void

type GetImageInfoCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取图片信息 */
export function getImageInfo<T extends GetImageInfoOptions = GetImageInfoOptions>(
  options: T
): AsyncReturn<T, GetImageInfoOptions> {
  return wrapperAsyncAPI(options => {
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

interface CompressImageOptions {
  /** 图片的路径，支持本地路径、代码包路径 */
  src: string
  /** 压缩质量，范围0～100，数值越小，质量越低，压缩率越高 */
  quality?: number
  /** 接口调用成功的回调函数 */
  success?: CompressImageSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CompressImageFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CompressImageCompleteCallback
}

interface CompressImageSuccessCallbackResult {
  /** 压缩后图片的临时文件路径 (本地路径)，jpg 格式 */
  tempFilePath: string
}

type CompressImageSuccessCallback = (res: CompressImageSuccessCallbackResult) => void

type CompressImageFailCallback = (res: GeneralCallbackResult) => void

type CompressImageCompleteCallback = (res: GeneralCallbackResult) => void

/** 压缩图片 */
export function compressImage<T extends CompressImageOptions = CompressImageOptions>(
  options: T
): AsyncReturn<T, CompressImageOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.COMPRESS_IMAGE
      if (!options.src) {
        invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "src"))
        return
      }

      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { quality: 80 }
  )
}
