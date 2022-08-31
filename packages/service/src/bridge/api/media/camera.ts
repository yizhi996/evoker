import { InnerJSBridge } from "../../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn
} from "@evoker/bridge"
import { getCurrentWebViewId } from "../../../app"

interface CameraContextTakePhotoOptions {
  /** 成像质量
   * 
   * 可选值：
   * - high: 高质量
   * - normal: 普通质量
   * - low: 低质量
   */
  quality?: "low" | "normal" | "high"
  /** 接口调用成功的回调函数 */
  success?: CameraContextTakePhotoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CameraContextTakePhotoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CameraContextTakePhotoCompleteCallback
}

interface CameraContextTakePhotoSuccessCallbackResult {
  /** 照片文件的临时路径 (本地路径) */
  tempImagePath: string
}

type CameraContextTakePhotoSuccessCallback = (
  res: CameraContextTakePhotoSuccessCallbackResult
) => void

type CameraContextTakePhotoFailCallback = (res: GeneralCallbackResult) => void

type CameraContextTakePhotoCompleteCallback = (res: GeneralCallbackResult) => void

interface CameraContextStartRecordOptions {
  /** 接口调用成功的回调函数 */
  success?: CameraContextStartRecordSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CameraContextStartRecordFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CameraContextStartRecordCompleteCallback
}

type CameraContextStartRecordSuccessCallback = (res: GeneralCallbackResult) => void

type CameraContextStartRecordFailCallback = (res: GeneralCallbackResult) => void

type CameraContextStartRecordCompleteCallback = (res: GeneralCallbackResult) => void

interface CameraContextStopRecordOptions {
  /** 压缩视频 */
  compressed?: boolean
  /** 接口调用成功的回调函数 */
  success?: CameraContextStopRecordSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CameraContextStopRecordFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CameraContextStopRecordCompleteCallback
}

interface CameraContextStopRecordSuccessCallbackResult {
  /** 封面图片文件的临时路径 (本地路径) */
  tempThumbPath: string
  /** 视频文件的临时路径 (本地路径) */
  tempVideoPath: string
}

type CameraContextStopRecordSuccessCallback = (
  res: CameraContextStopRecordSuccessCallbackResult
) => void

type CameraContextStopRecordFailCallback = (res: GeneralCallbackResult) => void

type CameraContextStopRecordCompleteCallback = (res: GeneralCallbackResult) => void

interface CameraContextSetZoomOptions {
  /** 缩放级别，范围[1, maxZoom]。zoom 可取小数，精确到小数后一位。maxZoom 可在 initdone 返回值中获取 */
  zoom: number
  /** 接口调用成功的回调函数 */
  success?: CameraContextSetZoomSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CameraContextSetZoomFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CameraContextSetZoomCompleteCallback
}

interface CameraContextSetZoomSuccessCallbackResult {
  /** 实际设置的缩放级别 */
  zoom: number
}

type CameraContextSetZoomSuccessCallback = (res: CameraContextSetZoomSuccessCallbackResult) => void

type CameraContextSetZoomFailCallback = (res: GeneralCallbackResult) => void

type CameraContextSetZoomCompleteCallback = (res: GeneralCallbackResult) => void

const enum Methods {
  TAKE_PHOTO = "takePhoto",
  START_RECORD = "startRecord",
  STOP_RECORD = "stopRecord",
  SET_ZOOM = "setZoom"
}

/** CameraContext 实例，可通过 ek.createCameraContext 获取，操作 camera 组件。 */
class CameraContext {
  cameraId: number

  constructor(cameraId: number) {
    this.cameraId = cameraId
  }

  /** 拍摄照片 */
  takePhoto<T extends CameraContextTakePhotoOptions = CameraContextTakePhotoOptions>(
    options: T
  ): AsyncReturn<T, CameraContextTakePhotoOptions> {
    return wrapperAsyncAPI(
      options => {
        if (!["low", "normal", "high"].includes(options.quality)) {
          options.quality = "normal"
        }
        InnerJSBridge.invoke<SuccessResult<T>>(
          "operateCamera",
          {
            cameraId: this.cameraId,
            method: Methods.TAKE_PHOTO,
            data: options
          },
          result => {
            invokeCallback(Methods.TAKE_PHOTO, options, result)
          }
        )
      },
      options,
      { quality: "normal" }
    )
  }

  /** 开始录像 */
  startRecord<T extends CameraContextStartRecordOptions = CameraContextStartRecordOptions>(
    options: T
  ): AsyncReturn<T, CameraContextStartRecordOptions> {
    return wrapperAsyncAPI(options => {
      InnerJSBridge.invoke<SuccessResult<T>>(
        "operateCamera",
        { cameraId: this.cameraId, method: Methods.START_RECORD, data: options },
        result => {
          invokeCallback(Methods.START_RECORD, options, result)
        }
      )
    }, options)
  }

  /** 结束录像 */
  stopRecord<T extends CameraContextStopRecordOptions = CameraContextStopRecordOptions>(
    options: T
  ): AsyncReturn<T, CameraContextStopRecordOptions> {
    return wrapperAsyncAPI(
      options => {
        InnerJSBridge.invoke<SuccessResult<T>>(
          "operateCamera",
          {
            cameraId: this.cameraId,
            method: Methods.STOP_RECORD,
            data: options
          },
          result => {
            invokeCallback(Methods.STOP_RECORD, options, result)
          }
        )
      },
      options,
      { compressed: false }
    )
  }

  /** 设置缩放级别 */
  setZoom<T extends CameraContextSetZoomOptions = CameraContextSetZoomOptions>(
    options: T
  ): AsyncReturn<T, CameraContextSetZoomOptions> {
    return wrapperAsyncAPI(options => {
      InnerJSBridge.invoke<SuccessResult<T>>(
        "operateCamera",
        {
          cameraId: this.cameraId,
          method: Methods.SET_ZOOM,
          data: options
        },
        result => {
          invokeCallback(Methods.SET_ZOOM, options, result)
        }
      )
    }, options)
  }
}

/** 创建 camera 组件的上下文 */
export function createCameraContext(): CameraContext {
  const pageId = getCurrentWebViewId()
  return new CameraContext(pageId)
}
