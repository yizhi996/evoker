import { invoke } from "../../bridge"
import { TempFile } from "./camera"

interface OpenNativelyAlbumTakePhotoOptions {
  count: number
  sizeType: Array<"original" | "compressed">
}

interface OpenNativelyAlbumTakePhotoResult {
  tempFilePaths: string[]
  tempFiles: TempFile[]
}

export function openNativelyAlbumTakePhoto(
  options: OpenNativelyAlbumTakePhotoOptions
): Promise<OpenNativelyAlbumTakePhotoResult> {
  return new Promise((resolve, reject) => {
    invoke<OpenNativelyAlbumTakePhotoResult>(
      "openNativelyAlbum",
      { types: ["photo"], count: options.count, sizeType: options.sizeType },
      result => {
        result.errMsg ? reject(result.errMsg) : resolve(result.data!)
      }
    )
  })
}
