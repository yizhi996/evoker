import { invoke } from "../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../async"
import { isString } from "@vue/shared"
import { ErrorCodes, errorMessage } from "../errors"
import { EKFILE_SCHEME, EKFILE_TMP, EKFILE_STORE } from "./const"

const enum Events {
  SAVE_FILE = "saveFile",
  REMOVE_SAVED_FILE = "removeSavedFile",
  GET_SAVED_FILE_LIST = "getSavedFileList",
  GET_SAVEF_FILE_INFO = "getSavedFileInfo",
  GET_FILE_INFO = "getFileInfo"
}

interface SaveFileOptions {
  tempFilePath: string
  success?: SaveFileSuccessCallback
  fail?: SaveFileFailCallback
  complete?: SaveFileCompleteCallback
}

type SaveFileSuccessCallback = (res: GeneralCallbackResult) => void

type SaveFileFailCallback = (res: GeneralCallbackResult) => void

type SaveFileCompleteCallback = (res: GeneralCallbackResult) => void

export function saveFile<T extends SaveFileOptions = SaveFileOptions>(
  options: T
): AsyncReturn<T, SaveFileOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SAVE_FILE

    if (!options.tempFilePath || !isString(options.tempFilePath)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "tempFilePath"))
      return
    }

    if (!options.tempFilePath.startsWith(EKFILE_TMP + "_")) {
      invokeFailure(event, options, `${options.tempFilePath} is not tmp file`)
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface RemoveSavedFileOptions {
  filePath: string
  success?: RemoveSavedFileSuccessCallback
  fail?: RemoveSavedFileFailCallback
  complete?: RemoveSavedFileCompleteCallback
}

type RemoveSavedFileSuccessCallback = (res: GeneralCallbackResult) => void

type RemoveSavedFileFailCallback = (res: GeneralCallbackResult) => void

type RemoveSavedFileCompleteCallback = (res: GeneralCallbackResult) => void

export function removeSavedFile<T extends RemoveSavedFileOptions = RemoveSavedFileOptions>(
  options: T
): AsyncReturn<T, RemoveSavedFileOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.REMOVE_SAVED_FILE

    if (!options.filePath || !isString(options.filePath)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "filePath"))
      return
    }

    if (!options.filePath.startsWith(EKFILE_STORE)) {
      invokeFailure(event, options, `${options.filePath} is not saved file`)
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetSavedFileListOptions {
  success?: GetSavedFileListSuccessCallback
  fail?: GetSavedFileListFailCallback
  complete?: GetSavedFileListCompleteCallback
}

interface FileItem {
  filePath: string
  size: number
  createTime: number
}

interface GetSavedFileListSuccessCallbackResult {
  fileList: FileItem[]
}

type GetSavedFileListSuccessCallback = (res: GetSavedFileListSuccessCallbackResult) => void

type GetSavedFileListFailCallback = (res: GeneralCallbackResult) => void

type GetSavedFileListCompleteCallback = (res: GeneralCallbackResult) => void

export function getSavedFileList<T extends GetSavedFileListOptions = GetSavedFileListOptions>(
  options: T
): AsyncReturn<T, GetSavedFileListOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_SAVED_FILE_LIST
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetSavedFileInfoOptions {
  filePath: string
  success?: GetSavedFileInfoSuccessCallback
  fail?: GetSavedFileInfoFailCallback
  complete?: GetSavedFileInfoCompleteCallback
}

interface GetSavedFileInfoSuccessCallbackResult {
  size: number
  createTime: number
}

type GetSavedFileInfoSuccessCallback = (res: GetSavedFileInfoSuccessCallbackResult) => void

type GetSavedFileInfoFailCallback = (res: GeneralCallbackResult) => void

type GetSavedFileInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getSavedFileInfo<T extends GetSavedFileInfoOptions = GetSavedFileInfoOptions>(
  options: T
): AsyncReturn<T, GetSavedFileInfoOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_SAVEF_FILE_INFO

    if (!options.filePath || !isString(options.filePath)) {
      invokeFailure(event, options, errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "filePath"))
      return
    }

    if (!options.filePath.startsWith(EKFILE_STORE)) {
      invokeFailure(event, options, `${options.filePath} is not saved file`)
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetFileInfoOptions {
  filePath: string
  digestAlgorithm?: "md5" | "sha1"
  success?: GetFileInfoSuccessCallback
  fail?: GetFileInfoFailCallback
  complete?: GetFileInfoCompleteCallback
}

interface GetFileInfoSuccessCallbackResult {
  size: number
  digest: string
}

type GetFileInfoSuccessCallback = (res: GetFileInfoSuccessCallbackResult) => void

type GetFileInfoFailCallback = (res: GeneralCallbackResult) => void

type GetFileInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getFileInfo<T extends GetFileInfoOptions = GetFileInfoOptions>(
  options: T
): AsyncReturn<T, GetFileInfoOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.GET_FILE_INFO

      if (!options.filePath || !isString(options.filePath)) {
        invokeFailure(event, options, errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "filePath"))
        return
      }

      if (!options.filePath.startsWith(EKFILE_SCHEME)) {
        invokeFailure(event, options, `${options.filePath} is not location file`)
        return
      }

      invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { digestAlgorithm: "md5" }
  )
}
