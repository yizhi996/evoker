import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

interface CameraContextTakePhotoOptions {
  quality?: "low" | "normal" | "high"
  success?: CameraContextTakePhotoSuccessCallback
  fail?: CameraContextTakePhotoFailCallback
  complete?: CameraContextTakePhotoCompleteCallback
}

interface CameraContextTakePhotoSuccessCallbackResult {
  tempImagePath: string
}

type CameraContextTakePhotoSuccessCallback = (
  res: CameraContextTakePhotoSuccessCallbackResult
) => void

type CameraContextTakePhotoFailCallback = (res: GeneralCallbackResult) => void

type CameraContextTakePhotoCompleteCallback = (
  res: GeneralCallbackResult
) => void

interface CameraContextStartRecordOptions {
  success?: CameraContextStartRecordSuccessCallback
  fail?: CameraContextStartRecordFailCallback
  complete?: CameraContextStartRecordCompleteCallback
}

type CameraContextStartRecordSuccessCallback = (
  res: GeneralCallbackResult
) => void

type CameraContextStartRecordFailCallback = (res: GeneralCallbackResult) => void

type CameraContextStartRecordCompleteCallback = (
  res: GeneralCallbackResult
) => void

interface CameraContextStopRecordOptions {
  compressed?: boolean
  success?: CameraContextStopRecordSuccessCallback
  fail?: CameraContextStopRecordFailCallback
  complete?: CameraContextStopRecordCompleteCallback
}

interface CameraContextStopRecordSuccessCallbackResult {
  tempThumbPath: string
  tempVideoPath: string
}

type CameraContextStopRecordSuccessCallback = (
  res: CameraContextStopRecordSuccessCallbackResult
) => void

type CameraContextStopRecordFailCallback = (res: GeneralCallbackResult) => void

type CameraContextStopRecordCompleteCallback = (
  res: GeneralCallbackResult
) => void

interface CameraContextSetZoomOptions {
  zoom: number
  success?: CameraContextSetZoomSuccessCallback
  fail?: CameraContextSetZoomFailCallback
  complete?: CameraContextSetZoomCompleteCallback
}

type CameraContextSetZoomSuccessCallback = (res: GeneralCallbackResult) => void

type CameraContextSetZoomFailCallback = (res: GeneralCallbackResult) => void

type CameraContextSetZoomCompleteCallback = (res: GeneralCallbackResult) => void

class CameraContext {
  takePhoto<
    T extends CameraContextTakePhotoOptions = CameraContextTakePhotoOptions
  >(options: T): AsyncReturn<T, CameraContextTakePhotoOptions> {
    return wrapperAsyncAPI<T>(options => {
      invoke<SuccessResult<T>>(
        "operateCamera",
        {
          cameraId: 1,
          method: "takePhoto",
          data: { quality: options.quality || "normal" }
        },
        result => {
          invokeCallback("takePhoto", options, result)
        }
      )
    }, options)
  }

  startRecord<
    T extends CameraContextStartRecordOptions = CameraContextStartRecordOptions
  >(options: T): AsyncReturn<T, CameraContextStartRecordOptions> {
    return wrapperAsyncAPI<T>(options => {
      invoke<SuccessResult<T>>(
        "operateCamera",
        { cameraId: 1, method: "startRecord", data: {} },
        result => {
          invokeCallback("startRecord", options, result)
        }
      )
    }, options)
  }

  stopRecord<
    T extends CameraContextStopRecordOptions = CameraContextStopRecordOptions
  >(options: T): AsyncReturn<T, CameraContextStopRecordOptions> {
    return wrapperAsyncAPI<T>(options => {
      invoke<SuccessResult<T>>(
        "operateCamera",
        {
          cameraId: 1,
          method: "stopRecord",
          data: { compressed: options.compressed ?? false }
        },
        result => {
          invokeCallback("stopRecord", options, result)
        }
      )
    }, options)
  }

  setZoom<T extends CameraContextSetZoomOptions = CameraContextSetZoomOptions>(
    options: T
  ): AsyncReturn<T, CameraContextSetZoomOptions> {
    return wrapperAsyncAPI<T>(options => {
      invoke<SuccessResult<T>>(
        "operateCamera",
        { cameraId: 1, method: "setZoom", data: { zoom: options.zoom } },
        result => {
          invokeCallback("setZoom", options, result)
        }
      )
    }, options)
  }
}

export function createCameraContext(): CameraContext {
  return new CameraContext()
}

export interface TempFile {
  path: string
  size: number
}

interface OpenNativeCameraTakePhotoResult {
  tempFilePath: string
  tempFile: TempFile
}

/**
 * 弹出原生相机拍摄照片
 * @returns
 */
export function openNativelyCameraTakePhoto(
  sizeType: Array<"original" | "compressed">
): Promise<OpenNativeCameraTakePhotoResult> {
  return new Promise((resolve, reject) => {
    invoke<OpenNativeCameraTakePhotoResult>(
      "openNativelyCamera",
      { type: "photo", sizeType },
      result => {
        result.errMsg ? reject(result.errMsg) : resolve(result.data!)
      }
    )
  })
}

interface OpenNativeCameraRecordVideoResult {
  tempFilePath: string
  duration: number
  size: number
  width: number
  height: number
}

/**
 * 弹出原生相机录制视频
 * @returns
 */
export function openNativelyCameraRecordVideo(): Promise<OpenNativeCameraRecordVideoResult> {
  return new Promise((resolve, reject) => {
    invoke<OpenNativeCameraRecordVideoResult>(
      "openNativelyCamera",
      { type: "video" },
      result => {
        result.errMsg ? reject(result.errMsg) : resolve(result.data!)
      }
    )
  })
}
