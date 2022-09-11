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
import { EKFILE_SCHEME, EKFILE_TMP, EKFILE_STORE } from "./const"
import { ERR_CANNOT_EMPTY, ERR_INVALID_ARG_TYPE, ERR_INVALID_ARG_VALUE } from "../errors"

const enum Events {
  SAVE_FILE = "saveFile",
  REMOVE_SAVED_FILE = "removeSavedFile",
  GET_SAVED_FILE_LIST = "getSavedFileList",
  GET_SAVEF_FILE_INFO = "getSavedFileInfo",
  GET_FILE_INFO = "getFileInfo"
}

interface SaveFileOptions {
  /** 需要保存的文件的临时路径 (本地路径) */
  tempFilePath: string
  /** 接口调用成功的回调函数 */
  success?: SaveFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SaveFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SaveFileCompleteCallback
}

interface SaveFileSuccessCallbackResult {
  /** 存储后的文件路径 (本地路径) */
  savedFilePath: string
}

type SaveFileSuccessCallback = (res: SaveFileSuccessCallbackResult) => void

type SaveFileFailCallback = (res: GeneralCallbackResult) => void

type SaveFileCompleteCallback = (res: GeneralCallbackResult) => void

/** 保存文件到本地
 *
 * 注意：saveFile 会把临时文件移动，因此调用成功后传入的 tempFilePath 将不可用
 */
export function saveFile<T extends SaveFileOptions = SaveFileOptions>(
  options: T
): AsyncReturn<T, SaveFileOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SAVE_FILE

    if (!isString(options.tempFilePath)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.tempFilePath", "string", options.tempFilePath)
      )
      return
    }

    if (!options.tempFilePath) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.tempFilePath", options.tempFilePath, ERR_CANNOT_EMPTY)
      )
      return
    }

    if (!options.tempFilePath.startsWith(EKFILE_TMP)) {
      invokeFailure(event, options, `${options.tempFilePath} is not tmp file`)
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

export interface RemoveSavedFileOptions {
  /** 需要删除的文件路径 (本地路径) */
  filePath: string
  /** 接口调用成功的回调函数 */
  success?: RemoveSavedFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: RemoveSavedFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: RemoveSavedFileCompleteCallback
}

type RemoveSavedFileSuccessCallback = (res: GeneralCallbackResult) => void

type RemoveSavedFileFailCallback = (res: GeneralCallbackResult) => void

type RemoveSavedFileCompleteCallback = (res: GeneralCallbackResult) => void

/** 删除本地缓存文件 */
export function removeSavedFile<T extends RemoveSavedFileOptions = RemoveSavedFileOptions>(
  options: T
): AsyncReturn<T, RemoveSavedFileOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.REMOVE_SAVED_FILE

    if (!isString(options.filePath)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.filePath", "string", options.filePath)
      )
      return
    }

    if (!options.filePath) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.filePath", options.filePath, ERR_CANNOT_EMPTY)
      )
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

export interface GetSavedFileListOptions {
  /** 接口调用成功的回调函数 */
  success?: GetSavedFileListSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetSavedFileListFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetSavedFileListCompleteCallback
}

interface FileItem {
  /** 文件路径 (本地路径) */
  filePath: string
  /** 本地文件大小，以字节为单位 */
  size: number
  /** 文件保存时的时间戳，从1970/01/01 08:00:00 到当前时间的秒数 */
  createTime: number
}

interface GetSavedFileListSuccessCallbackResult {
  /** 文件数组 */
  fileList: FileItem[]
}

type GetSavedFileListSuccessCallback = (res: GetSavedFileListSuccessCallbackResult) => void

type GetSavedFileListFailCallback = (res: GeneralCallbackResult) => void

type GetSavedFileListCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取该小程序下已保存的本地缓存文件列表 */
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
  /** 文件路径 (本地路径) */
  filePath: string
  /** 接口调用成功的回调函数 */
  success?: GetSavedFileInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetSavedFileInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetSavedFileInfoCompleteCallback
}

interface GetSavedFileInfoSuccessCallbackResult {
  /** 文件大小，单位 B */
  size: number
  /** 文件保存时的时间戳，从1970/01/01 08:00:00 到该时刻的秒数 */
  createTime: number
}

type GetSavedFileInfoSuccessCallback = (res: GetSavedFileInfoSuccessCallbackResult) => void

type GetSavedFileInfoFailCallback = (res: GeneralCallbackResult) => void

type GetSavedFileInfoCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取本地文件的文件信息。此接口只能用于获取已保存到本地的文件 */
export function getSavedFileInfo<T extends GetSavedFileInfoOptions = GetSavedFileInfoOptions>(
  options: T
): AsyncReturn<T, GetSavedFileInfoOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_SAVEF_FILE_INFO

    if (!isString(options.filePath)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.filePath", "string", options.filePath)
      )
      return
    }

    if (!options.filePath) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.filePath", options.filePath, ERR_CANNOT_EMPTY)
      )
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

export interface GetFileInfoOptions {
  /** 本地文件路径 (本地路径) */
  filePath: string
  /** 计算文件摘要的算法
   *
   * 可选值：
   * - md5: md5 算法
   * - sha1: sha1 算法
   */
  digestAlgorithm?: "md5" | "sha1"
  /** 接口调用成功的回调函数 */
  success?: GetFileInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetFileInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetFileInfoCompleteCallback
}

interface GetFileInfoSuccessCallbackResult {
  /** 文件大小，单位 B */
  size: number
  /** 按照传入的 digestAlgorithm 计算得出的的文件摘要 */
  digest: string
}

type GetFileInfoSuccessCallback = (res: GetFileInfoSuccessCallbackResult) => void

type GetFileInfoFailCallback = (res: GeneralCallbackResult) => void

type GetFileInfoCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取文件信息 */
export function getFileInfo<T extends GetFileInfoOptions = GetFileInfoOptions>(
  options: T
): AsyncReturn<T, GetFileInfoOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.GET_FILE_INFO

      if (!isString(options.filePath)) {
        invokeFailure(
          event,
          options,
          ERR_INVALID_ARG_TYPE("options.filePath", "string", options.filePath)
        )
        return
      }

      if (!options.filePath) {
        invokeFailure(
          event,
          options,
          ERR_INVALID_ARG_VALUE("options.filePath", options.filePath, ERR_CANNOT_EMPTY)
        )
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
