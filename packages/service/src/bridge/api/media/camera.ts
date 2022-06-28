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

type CameraContextTakePhotoCompleteCallback = (res: GeneralCallbackResult) => void

interface CameraContextStartRecordOptions {
  success?: CameraContextStartRecordSuccessCallback
  fail?: CameraContextStartRecordFailCallback
  complete?: CameraContextStartRecordCompleteCallback
}

type CameraContextStartRecordSuccessCallback = (res: GeneralCallbackResult) => void

type CameraContextStartRecordFailCallback = (res: GeneralCallbackResult) => void

type CameraContextStartRecordCompleteCallback = (res: GeneralCallbackResult) => void

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

type CameraContextStopRecordCompleteCallback = (res: GeneralCallbackResult) => void

interface CameraContextSetZoomOptions {
  zoom: number
  success?: CameraContextSetZoomSuccessCallback
  fail?: CameraContextSetZoomFailCallback
  complete?: CameraContextSetZoomCompleteCallback
}

interface CameraContextSetZoomSuccessCallbackResult {
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

class CameraContext {
  cameraId: number

  constructor(cameraId: number) {
    this.cameraId = cameraId
  }

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

export function createCameraContext(): CameraContext {
  const pageId = getCurrentWebViewId()
  return new CameraContext(pageId)
}
