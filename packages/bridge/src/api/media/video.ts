import { openNativelyCameraRecordVideo } from "./camera"
import { openNativelyAlbumChooseVideo } from "./album"
import { showActionSheet } from "../ui/interaction"
import {
  invokeSuccess,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  wrapperAsyncAPI,
  invokeCallback,
  SuccessResult
} from "../../async"
import { invoke } from "../../bridge"
import { clamp } from "@evoker/shared"
import { ErrorCodes, errorMessage } from "../../errors"
import { requestAuthorization } from "../auth"

const enum Events {
  CHOOSE_VIDEO = "chooseVideo",
  SAVE_VIDEO_TO_PHTOTS_ALBUM = "saveVideoToPhotosAlbum",
  GET_VIDEO_INFO = "getVideoInfo",
  COMPTESS_VIDEO = "compressVideo"
}

interface ChooseVideoOptions {
  /** 视频选择的来源
   *
   * 可选值：
   * - album: 从相册选择视频
   * - camera: 使用相机拍摄视频
   */
  sourceType?: Array<"album" | "camera">
  /** 是否压缩所选择的视频文件 */
  compressed?: boolean
  /** 摄视频最长拍摄时间，单位秒 */
  maxDuration?: number
  /** 默认拉起的是前置或者后置摄像头
   * 
   * 可选值：
   * - back: 默认拉起后置摄像头
   * -front: 默认拉起前置摄像头
   */
  camera?: "back" | "front"
  /** 接口调用成功的回调函数 */
  success?: ChooseVideoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ChooseVideoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ChooseVideoCompleteCallback
}

interface ChooseVideoSuccessCallbackResult {
  /** 视频的本地临时文件路径列表 (本地路径) */
  tempFilePath: string
  /** 频的时间长度 */
  duration: number
  /** 视频的数据量大小 */
  size: number
  /** 视频的宽度 */
  width: number
  /** 视频的高度 */
  height: number
}

type ChooseVideoSuccessCallback = (res: ChooseVideoSuccessCallbackResult) => void

type ChooseVideoFailCallback = (res: GeneralCallbackResult) => void

type ChooseVideoCompleteCallback = (res: GeneralCallbackResult) => void

/** 从本地相册选择视频或使用相机拍摄 */
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
        openNativelyCameraRecordVideo(sizeType, options.maxDuration, options.camera)
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
      camera: "back"
    }
  )
}

interface SaveVideoToPhotosAlbumOptions {
  /** 视频文件路径，可以是临时文件路径或永久文件路径 (本地路径)，不支持网络路径 */
  filePath: string
  /** 接口调用成功的回调函数 */
  success?: SaveVideoToPhotosAlbumSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SaveVideoToPhotosAlbumFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SaveVideoToPhotosAlbumCompleteCallback
}

type SaveVideoToPhotosAlbumSuccessCallback = (res: GeneralCallbackResult) => void

type SaveVideoToPhotosAlbumFailCallback = (res: GeneralCallbackResult) => void

type SaveVideoToPhotosAlbumCompleteCallback = (res: GeneralCallbackResult) => void

/** 保存视频到系统相册。支持 mp4, mov 格式 */
export function saveVideoToPhotosAlbum<
  T extends SaveVideoToPhotosAlbumOptions = SaveVideoToPhotosAlbumOptions
>(options: T): AsyncReturn<T, SaveVideoToPhotosAlbumOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SAVE_VIDEO_TO_PHTOTS_ALBUM
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

interface GetVideoInfoOptions {
  /** 视频文件路径，可以是临时文件路径也可以是永久文件路径 */
  src: string
  /** 接口调用成功的回调函数 */
  success?: GetVideoInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetVideoInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetVideoInfoCompleteCallback
}

interface GetVideoInfoSuccessCallbackResult {
  /** 视频的格式 */
  type: string
  /** 视频的长度 */
  duration: number
  /** 视频的大小，单位 KB */
  size: number
  /** 视频的宽度 */
  width: number
  /** 视频的高度 */
  height: number
  /** 视频的帧率 */
  fps: number
  /** 视频的码率，单位 kbps */
  bitrate: number
}

type GetVideoInfoSuccessCallback = (res: GetVideoInfoSuccessCallbackResult) => void

type GetVideoInfoFailCallback = (res: GeneralCallbackResult) => void

type GetVideoInfoCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取视频信息 */
export function getVideoInfo<T extends GetVideoInfoOptions = GetVideoInfoOptions>(
  options: T
): AsyncReturn<T, GetVideoInfoOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_VIDEO_INFO
    if (!options.src) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "src"))
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface CompressVideoOptions {
  /** 视频文件路径，可以是临时文件路径也可以是永久文件路径 */
  src: string
  /** 压缩质量
   * 
   * 可选值：
   * - low: 低
   * - medium: 中
   * - high: 高
   */
  quality?: "low" | "medium" | "high"
  /** 码率，单位 kbps */
  bitrate?: number
  /** 帧率 */
  fps?: number
  /** 相对于原视频的分辨率比例，取值范围 0 - 1 */
  resolution?: number
  /** 接口调用成功的回调函数 */
  success?: CompressVideoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CompressVideoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CompressVideoCompleteCallback
}

interface CompressVideoSuccessCallbackResult {
  /** 压缩后的临时文件地址 */
  tempFilePath: string
  /** 压缩后的大小，单位 KB */
  size:number
}

type CompressVideoSuccessCallback = (res: CompressVideoSuccessCallbackResult) => void

type CompressVideoFailCallback = (res: GeneralCallbackResult) => void

type CompressVideoCompleteCallback = (res: GeneralCallbackResult) => void

/** 压缩视频
 * 
 * 当需要更精细的控制时，可指定 bitrate、fps、和 resolution，当 quality 传入时，这三个参数将被忽略。 */
export function compressVideo<T extends CompressVideoOptions = CompressVideoOptions>(
  options: T
): AsyncReturn<T, CompressVideoOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.COMPTESS_VIDEO
      if (!options.src) {
        invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "src"))
        return
      }
      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { resolution: 1 }
  )
}
