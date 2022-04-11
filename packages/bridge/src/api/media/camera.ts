import { invoke } from "../../bridge"

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
export function openNativelyCameraRecordVideo(
  sizeType: Array<"original" | "compressed">,
  maxDuration: number,
  cameraDevice: "back" | "front"
): Promise<OpenNativeCameraRecordVideoResult> {
  return new Promise((resolve, reject) => {
    invoke<OpenNativeCameraRecordVideoResult>(
      "openNativelyCamera",
      { type: "video", sizeType, maxDuration, cameraDevice },
      result => {
        result.errMsg ? reject(result.errMsg) : resolve(result.data!)
      }
    )
  })
}
