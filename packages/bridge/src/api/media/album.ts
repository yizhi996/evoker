import { invoke } from "../../bridge"
import { TempFile } from "./camera"

interface OpenNativelyAlbumChoosePhotoOptions {
  count: number
  sizeType: Array<"original" | "compressed">
}

interface OpenNativelyAlbumChoosePhotoResult {
  tempFilePaths: string[]
  tempFiles: TempFile[]
}

export function openNativelyAlbumChoosePhoto(
  options: OpenNativelyAlbumChoosePhotoOptions
): Promise<OpenNativelyAlbumChoosePhotoResult> {
  return new Promise((resolve, reject) => {
    invoke<OpenNativelyAlbumChoosePhotoResult>(
      "openNativelyAlbum",
      { types: ["photo"], count: options.count, sizeType: options.sizeType },
      result => {
        result.errMsg ? reject(result.errMsg) : resolve(result.data!)
      }
    )
  })
}

interface OpenNativelyAlbumTakeChooseVideoResult {
  tempFilePath: string
  duration: number
  size: number
  width: number
  height: number
}

export function openNativelyAlbumChooseVideo(
  sizeType: Array<"original" | "compressed">
): Promise<OpenNativelyAlbumTakeChooseVideoResult> {
  return new Promise((resolve, reject) => {
    invoke<OpenNativelyAlbumTakeChooseVideoResult>(
      "openNativelyAlbum",
      { types: ["video"], count: 1, sizeType },
      result => {
        result.errMsg ? reject(result.errMsg) : resolve(result.data!)
      }
    )
  })
}
