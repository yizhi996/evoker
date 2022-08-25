import { invoke } from "../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure,
  invokeSuccess
} from "../async"
import { isArray, isString } from "@vue/shared"
import { ErrorCodes, errorMessage } from "../errors"
import { EKFILE_SCHEME, EKFILE_TMP, EKFILE_STORE, USER_DATA_PATH } from "./const"
import { isArrayBuffer } from "@evoker/shared"

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

let globalFileSystemManager: FileSystemManager | null = null

export function getFileSystemManager() {
  if (!globalFileSystemManager) {
    globalFileSystemManager = new FileSystemManager()
  }
  return globalFileSystemManager
}

interface AccessOptions {
  path: string
  success?: AccessSuccessCallback
  fail?: AccessFailCallback
  complete?: AccessCompleteCallback
}

type AccessSuccessCallback = (res: GeneralCallbackResult) => void

type AccessFailCallback = (res: GeneralCallbackResult) => void

type AccessCompleteCallback = (res: GeneralCallbackResult) => void

interface MkdirOptions {
  dirPath: string
  recursive?: boolean
  success?: MkdirSuccessCallback
  fail?: MkdirFailCallback
  complete?: MkdirCompleteCallback
}

type MkdirSuccessCallback = (res: GeneralCallbackResult) => void

type MkdirFailCallback = (res: GeneralCallbackResult) => void

type MkdirCompleteCallback = (res: GeneralCallbackResult) => void

interface RmdirOptions {
  dirPath: string
  recursive?: boolean
  success?: RmdirSuccessCallback
  fail?: RmdirFailCallback
  complete?: RmdirCompleteCallback
}

type RmdirSuccessCallback = (res: GeneralCallbackResult) => void

type RmdirFailCallback = (res: GeneralCallbackResult) => void

type RmdirCompleteCallback = (res: GeneralCallbackResult) => void

interface ReaddirOptions {
  dirPath: string
  success?: ReaddirSuccessCallback
  fail?: ReaddirFailCallback
  complete?: ReaddirCompleteCallback
}

interface ReaddirSuccessCallbackResult {
  files: string[]
}

type ReaddirSuccessCallback = (res: ReaddirSuccessCallbackResult) => void

type ReaddirFailCallback = (res: GeneralCallbackResult) => void

type ReaddirCompleteCallback = (res: GeneralCallbackResult) => void

type Encoding =
  | "ascii"
  | "base64"
  | "hex"
  | "ucs2"
  | "ucs-2"
  | "utf16le"
  | "utf-16le"
  | "utf-8"
  | "utf8"
  | "latin1"

interface ReadFileOptions {
  filePath: string
  encoding?: Encoding
  position?: number
  length?: number
  success?: ReadFileSuccessCallback
  fail?: ReadFileFailCallback
  complete?: ReadFileCompleteCallback
}

interface ReadFileSuccessCallbackResult {
  data: string | ArrayBuffer
}

type ReadFileSuccessCallback = (res: ReadFileSuccessCallbackResult) => void

type ReadFileFailCallback = (res: GeneralCallbackResult) => void

type ReadFileCompleteCallback = (res: GeneralCallbackResult) => void

interface WriteFileOptions {
  filePath: string
  data: string | ArrayBuffer
  encoding?: Encoding
  success?: WriteFileSuccessCallback
  fail?: WriteFileFailCallback
  complete?: WriteFileCompleteCallback
}

type WriteFileSuccessCallback = (res: GeneralCallbackResult) => void

type WriteFileFailCallback = (res: GeneralCallbackResult) => void

type WriteFileCompleteCallback = (res: GeneralCallbackResult) => void

interface RenameOptions {
  oldPath: string
  newPath: string
  success?: RenameSuccessCallback
  fail?: RenameFailCallback
  complete?: RenameCompleteCallback
}

type RenameSuccessCallback = (res: GeneralCallbackResult) => void

type RenameFailCallback = (res: GeneralCallbackResult) => void

type RenameCompleteCallback = (res: GeneralCallbackResult) => void

interface CopyOptions {
  srcPath: string
  destPath: string
  success?: CopySuccessCallback
  fail?: CopyFailCallback
  complete?: CopyCompleteCallback
}

type CopySuccessCallback = (res: GeneralCallbackResult) => void

type CopyFailCallback = (res: GeneralCallbackResult) => void

type CopyCompleteCallback = (res: GeneralCallbackResult) => void

interface AppendFileOptions {
  filePath: string
  data: string | ArrayBuffer
  encoding: Encoding
  success?: AppendFileSuccessCallback
  fail?: AppendFileFailCallback
  complete?: AppendFileCompleteCallback
}

type AppendFileSuccessCallback = (res: GeneralCallbackResult) => void

type AppendFileFailCallback = (res: GeneralCallbackResult) => void

type AppendFileCompleteCallback = (res: GeneralCallbackResult) => void

class FileSystemManager {
  access(options: AccessOptions) {
    const event = "access"
    try {
      this.accessSync(options.path)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  accessSync(path: string) {
    const event = "accessSync"

    validFilePath(event, path, "path", EKFILE_SCHEME)

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.access(path)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  mkdir(options: MkdirOptions) {
    const event = "mkdir"
    try {
      this.mkdirSync(options.dirPath, options.recursive)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  mkdirSync(dirPath: string, recursive: boolean = false) {
    const event = "mkdirSync"

    validFilePath(event, dirPath, "dirPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.mkdir(dirPath, recursive)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  rmdir(options: RmdirOptions) {
    const event = "rmdir"
    try {
      this.rmdirSync(options.dirPath, options.recursive)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  rmdirSync(dirPath: string, recursive: boolean = false) {
    const event = "rmdirSync"

    validFilePath(event, dirPath, "dirPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.rmdir(dirPath, recursive)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  readdir(options: ReaddirOptions) {
    const event = "readdir"
    try {
      const files = this.readdirSync(options.dirPath)
      invokeSuccess(event, options, { files })
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  readdirSync(dirPath: string) {
    const event = "readdirSync"

    validFilePath(event, dirPath, "dirPath", USER_DATA_PATH)

    const { files, errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.readdir(dirPath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    return files
  }

  readFile(options: ReadFileOptions) {
    const event = "readFile"
    try {
      const data = this.readFileSync(
        options.filePath,
        options.encoding,
        options.position,
        options.length
      )
      invokeSuccess(event, options, { data })
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  readFileSync(filePath: string, encoding?: Encoding, position?: number, length?: number) {
    const event = "readFileSync"

    validFilePath(event, filePath, "filePath", USER_DATA_PATH)

    let noHyphenEncoding = encoding && encoding.replaceAll("-", "")
    if (
      noHyphenEncoding &&
      !["ascii", "base64", "hex", "utf16le", "utf8", "latin1", "ucs2"].includes(noHyphenEncoding)
    ) {
      throw new Error(`${event}:fail unknown encoding: ${encoding}`)
    }

    const { data, errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.readFile({
      filePath,
      encoding: noHyphenEncoding,
      position,
      length
    })
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    if (isArray(data)) {
      return Uint8Array.from(data as number[]).buffer
    }
    return data
  }

  writeFile(options: WriteFileOptions) {
    const event = "writeFile"
    try {
      this.writeFileSync(options.filePath, options.data, options.encoding)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  writeFileSync(filePath: string, data: string | ArrayBuffer, encoding: Encoding = "utf8") {
    const event = "writeFileSync"

    validFilePath(event, filePath, "filePath", USER_DATA_PATH)

    let noHyphenEncoding = encoding && encoding.replaceAll("-", "")
    if (
      noHyphenEncoding &&
      !["ascii", "base64", "hex", "utf16le", "utf8", "latin1", "ucs2"].includes(noHyphenEncoding)
    ) {
      throw new Error(`${event}:fail unknown encoding: ${encoding}`)
    }

    let conver = data
    if (isArrayBuffer(data)) {
      conver = Array.from(new Uint8Array(data)) as any
    }

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.writeFile({
      filePath,
      data: conver,
      encoding: noHyphenEncoding
    })
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  rename(options: RenameOptions) {
    const event = "rename"
    try {
      this.renameSync(options.oldPath, options.newPath)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  renameSync(oldPath: string, newPath: string) {
    const event = "renameSync"

    validFilePath(event, oldPath, "oldPath", USER_DATA_PATH)

    validFilePath(event, newPath, "newPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.rename(oldPath, newPath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  copy(options: CopyOptions) {
    const event = "copy"
    try {
      this.copySync(options.srcPath, options.destPath)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  copySync(srcPath: string, destPath: string) {
    const event = "copySync"

    validFilePath(event, srcPath, "srcPath", USER_DATA_PATH)

    validFilePath(event, destPath, "destPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.copy(srcPath, destPath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  appendFile(options: AppendFileOptions) {
    const event = "appendFile"
    try {
      this.appendFileSync(options.filePath, options.data, options.encoding)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  appendFileSync(filePath: string, data: string | ArrayBuffer, encoding: Encoding = "utf8") {
    const event = "appendFileSync"

    validFilePath(event, filePath, "filePath", USER_DATA_PATH)

    let noHyphenEncoding = encoding && encoding.replaceAll("-", "")
    if (
      noHyphenEncoding &&
      !["ascii", "base64", "hex", "utf16le", "utf8", "latin1", "ucs2"].includes(noHyphenEncoding)
    ) {
      throw new Error(`${event}:fail unknown encoding: ${encoding}`)
    }

    let conver = data
    if (isArrayBuffer(data)) {
      conver = Array.from(new Uint8Array(data)) as any
    }

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.appendFile({
      filePath,
      data: conver,
      encoding: noHyphenEncoding
    })
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }
}

function validFilePath(event: string, path: string, name: string, startsWith: string) {
  if (!path || !isString(path)) {
    throw new Error(`${event}:fail ${errorMessage(ErrorCodes.CANNOT_BE_EMPTY, name)}`)
  }

  if (!path.startsWith(startsWith)) {
    throw new Error(`${event}:fail ${path} is not startsWith ${startsWith}`)
  }
}
