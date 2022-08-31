import { GeneralCallbackResult, invokeSuccess, invokeFailure } from "../async"
import { isString } from "@vue/shared"
import { ErrorCodes, errorMessage } from "../errors"
import { EKFILE_SCHEME, EKFILE_TMP, USER_DATA_PATH } from "./const"
import { isArrayBuffer } from "@evoker/shared"
import { getFileInfo, getSavedFileList, removeSavedFile } from "./file"
import type { GetFileInfoOptions, GetSavedFileListOptions, RemoveSavedFileOptions } from "./file"

const S_IFREG = 32768

const S_IFDIR = 16384

let globalFileSystemManager: FileSystemManager | null = null

export function getFileSystemManager() {
  if (!globalFileSystemManager) {
    globalFileSystemManager = new FileSystemManager()
  }
  return globalFileSystemManager
}

interface AccessOptions {
  path: string
  /** 接口调用成功的回调函数 */
  success?: AccessSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: AccessFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: AccessCompleteCallback
}

type AccessSuccessCallback = (res: GeneralCallbackResult) => void

type AccessFailCallback = (res: GeneralCallbackResult) => void

type AccessCompleteCallback = (res: GeneralCallbackResult) => void

interface MkdirOptions {
  dirPath: string
  recursive?: boolean
  /** 接口调用成功的回调函数 */
  success?: MkdirSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: MkdirFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: MkdirCompleteCallback
}

type MkdirSuccessCallback = (res: GeneralCallbackResult) => void

type MkdirFailCallback = (res: GeneralCallbackResult) => void

type MkdirCompleteCallback = (res: GeneralCallbackResult) => void

interface RmdirOptions {
  dirPath: string
  recursive?: boolean
  /** 接口调用成功的回调函数 */
  success?: RmdirSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: RmdirFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: RmdirCompleteCallback
}

type RmdirSuccessCallback = (res: GeneralCallbackResult) => void

type RmdirFailCallback = (res: GeneralCallbackResult) => void

type RmdirCompleteCallback = (res: GeneralCallbackResult) => void

interface ReaddirOptions {
  dirPath: string
  /** 接口调用成功的回调函数 */
  success?: ReaddirSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ReaddirFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
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
  | "binary"

interface ReadFileOptions {
  filePath: string
  encoding?: Encoding
  position?: number
  length?: number
  /** 接口调用成功的回调函数 */
  success?: ReadFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ReadFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
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
  /** 接口调用成功的回调函数 */
  success?: WriteFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: WriteFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: WriteFileCompleteCallback
}

type WriteFileSuccessCallback = (res: GeneralCallbackResult) => void

type WriteFileFailCallback = (res: GeneralCallbackResult) => void

type WriteFileCompleteCallback = (res: GeneralCallbackResult) => void

interface RenameOptions {
  oldPath: string
  newPath: string
  /** 接口调用成功的回调函数 */
  success?: RenameSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: RenameFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: RenameCompleteCallback
}

type RenameSuccessCallback = (res: GeneralCallbackResult) => void

type RenameFailCallback = (res: GeneralCallbackResult) => void

type RenameCompleteCallback = (res: GeneralCallbackResult) => void

interface CopyOptions {
  srcPath: string
  destPath: string
  /** 接口调用成功的回调函数 */
  success?: CopySuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CopyFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CopyCompleteCallback
}

type CopySuccessCallback = (res: GeneralCallbackResult) => void

type CopyFailCallback = (res: GeneralCallbackResult) => void

type CopyCompleteCallback = (res: GeneralCallbackResult) => void

interface AppendFileOptions {
  filePath: string
  data: string | ArrayBuffer
  encoding: Encoding
  /** 接口调用成功的回调函数 */
  success?: AppendFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: AppendFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: AppendFileCompleteCallback
}

type AppendFileSuccessCallback = (res: GeneralCallbackResult) => void

type AppendFileFailCallback = (res: GeneralCallbackResult) => void

type AppendFileCompleteCallback = (res: GeneralCallbackResult) => void

interface UnlinkOptions {
  filePath: string
  /** 接口调用成功的回调函数 */
  success?: UnlinkSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: UnlinkFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: UnlinkCompleteCallback
}

type UnlinkSuccessCallback = (res: GeneralCallbackResult) => void

type UnlinkFailCallback = (res: GeneralCallbackResult) => void

type UnlinkCompleteCallback = (res: GeneralCallbackResult) => void

interface StatOptions {
  path: string
  recursive?: boolean
  /** 接口调用成功的回调函数 */
  success?: StatSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: StatFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: StatCompleteCallback
}

interface StatSuccessCallbackResult {
  stats: Stats | Stats[]
}

type StatSuccessCallback = (res: StatSuccessCallbackResult) => void

type StatFailCallback = (res: GeneralCallbackResult) => void

type StatCompleteCallback = (res: GeneralCallbackResult) => void

interface SaveFileOptions {
  tempFilePath: string
  filePath?: string
  /** 接口调用成功的回调函数 */
  success?: SaveFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SaveFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SaveFileCompleteCallback
}

interface SaveFileSuccessCallbackResult {
  savedFilePath: string
}

type SaveFileSuccessCallback = (res: SaveFileSuccessCallbackResult) => void

type SaveFileFailCallback = (res: GeneralCallbackResult) => void

type SaveFileCompleteCallback = (res: GeneralCallbackResult) => void

type Flag = "a" | "ax" | "a+" | "ax+" | "as" | "as+" | "r" | "r+" | "w" | "wx" | "w+" | "wx+"

interface OpenOptions {
  filePath: string
  flag: Flag
  /** 接口调用成功的回调函数 */
  success?: OpenSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: OpenFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: OpenCompleteCallback
}

interface OpenSuccessCallbackResult {
  fd: string
}

type OpenSuccessCallback = (res: OpenSuccessCallbackResult) => void

type OpenFailCallback = (res: GeneralCallbackResult) => void

type OpenCompleteCallback = (res: GeneralCallbackResult) => void

interface CloseOptions {
  fd: string
  /** 接口调用成功的回调函数 */
  success?: CloseSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CloseFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CloseCompleteCallback
}

type CloseSuccessCallback = (res: GeneralCallbackResult) => void

type CloseFailCallback = (res: GeneralCallbackResult) => void

type CloseCompleteCallback = (res: GeneralCallbackResult) => void

interface FstatOptions {
  fd: string
  /** 接口调用成功的回调函数 */
  success?: FstatSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: FstatFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: FstatCompleteCallback
}

interface Stats {
  mode: number
  size: number
  lastAccessedTime: number
  lastModifiedTime: number
  isFile: () => boolean
  isDirectory: () => boolean
}

interface FstatSuccessCallbackResult {
  stats: Stats
}

type FstatSuccessCallback = (res: FstatSuccessCallbackResult) => void

type FstatFailCallback = (res: GeneralCallbackResult) => void

type FstatCompleteCallback = (res: GeneralCallbackResult) => void

interface FtruncateOptions {
  fd: string
  length: number
  /** 接口调用成功的回调函数 */
  success?: FtruncateSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: FtruncateFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: FtruncateCompleteCallback
}

type FtruncateSuccessCallback = (res: GeneralCallbackResult) => void

type FtruncateFailCallback = (res: GeneralCallbackResult) => void

type FtruncateCompleteCallback = (res: GeneralCallbackResult) => void

interface ReadOptions {
  fd: string
  arrayBuffer: ArrayBuffer
  offset?: number
  length?: number
  position?: number
  /** 接口调用成功的回调函数 */
  success?: ReadSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ReadFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ReadCompleteCallback
}

interface ReadResult {
  bytesRead: number
  arrayBuffer: ArrayBuffer
}

type ReadSuccessCallback = (res: ReadResult) => void

type ReadFailCallback = (res: GeneralCallbackResult) => void

type ReadCompleteCallback = (res: GeneralCallbackResult) => void

interface WriteOptions {
  fd: string
  data: string | ArrayBuffer
  encoding?: Encoding
  offset?: number
  length?: number
  position?: number
  /** 接口调用成功的回调函数 */
  success?: WriteSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: WriteFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: WriteCompleteCallback
}

interface WriteResult {
  bytesWritten: number
}

type WriteSuccessCallback = (res: WriteResult) => void

type WriteFailCallback = (res: GeneralCallbackResult) => void

type WriteCompleteCallback = (res: GeneralCallbackResult) => void

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

    const { errMsg } = globalThis.__FileSystem.access(path)
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

    const { errMsg } = globalThis.__FileSystem.mkdir(dirPath, recursive)
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

    const { errMsg } = globalThis.__FileSystem.rmdir(dirPath, recursive)
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

    const { files, errMsg } = globalThis.__FileSystem.readdir(dirPath)
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

    let noHyphenEncoding = "none"
    if (encoding) {
      noHyphenEncoding = formatAndValidEncoding(event, encoding)
    }

    const { data, errMsg } = globalThis.__FileSystem.readFile({
      filePath,
      encoding: noHyphenEncoding,
      position,
      length
    })
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
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

    const noHyphenEncoding = formatAndValidEncoding(event, encoding)

    if (!isArrayBuffer(data) && !isString(data)) {
      throw new Error(`${event}:fail data must be a string or ArrayBuffer`)
    }

    const { errMsg } = globalThis.__FileSystem.writeFile(filePath, data, noHyphenEncoding)
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

    const { errMsg } = globalThis.__FileSystem.rename(oldPath, newPath)
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

    const { errMsg } = globalThis.__FileSystem.copy(srcPath, destPath)
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

    const noHyphenEncoding = formatAndValidEncoding(event, encoding)

    if (!isArrayBuffer(data) && !isString(data)) {
      throw new Error(`${event}:fail data must be string or ArrayBuffer`)
    }

    const { errMsg } = globalThis.__FileSystem.appendFile(filePath, data, noHyphenEncoding)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  unlink(options: UnlinkOptions) {
    const event = "unlink"
    try {
      this.unlinkSync(options.filePath)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  unlinkSync(filePath: string) {
    const event = "unlinkSync"

    validFilePath(event, filePath, "filePath", USER_DATA_PATH)

    const { errMsg } = globalThis.__FileSystem.unlink(filePath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  stat(options: StatOptions) {
    const event = "stat"
    try {
      const stats = this.statSync(options.path, options.recursive)
      invokeSuccess(event, options, { stats })
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  statSync(path: string, recursive: boolean = false) {
    const event = "statSync"

    validFilePath(event, path, "path", USER_DATA_PATH)

    const { stats, errMsg } = globalThis.__FileSystem.stat(path, recursive)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    return stats as Stats | Stats[]
  }

  saveFile(options: SaveFileOptions) {
    const event = "saveFile"
    try {
      const savedFilePath = this.saveFileSync(options.tempFilePath, options.filePath)
      invokeSuccess(event, options, { savedFilePath })
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  saveFileSync(tempFilePath: string, filePath: string = "") {
    const event = "saveFileSync"

    validFilePath(event, tempFilePath, "tempFilePath", EKFILE_TMP)

    if (filePath) {
      validFilePath(event, filePath, "filePath", USER_DATA_PATH)
    }

    const { savedFilePath, errMsg } = globalThis.__FileSystem.saveFile(tempFilePath, filePath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    return savedFilePath
  }

  open(options: OpenOptions) {
    const event = "open"
    try {
      const fd = this.openSync(options)
      invokeSuccess(event, options, { fd })
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  openSync(options: Omit<OpenOptions, "success" | "fail" | "complete">) {
    const event = "openSync"

    const { filePath, flag = "r" } = options

    validFilePath(event, filePath, "filePath", USER_DATA_PATH)

    if (!["a", "ax", "a+", "ax+", "as", "as+", "r", "r+", "w", "wx", "w+", "wx+"].includes(flag)) {
      throw new Error(`${event}:fail invalid flag: ${flag}`)
    }

    const { fd, errMsg } = globalThis.__FileSystem.open(filePath, flag)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    return fd
  }

  close(options: CloseOptions) {
    const event = "close"
    try {
      this.closeSync(options)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  closeSync(options: Omit<CloseOptions, "success" | "fail" | "complete">) {
    const event = "closeSync"

    const { fd } = options

    if (!fd || !isString(fd)) {
      throw new Error(`${event}:fail ${errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "fd")}`)
    }

    const { errMsg } = globalThis.__FileSystem.close(fd)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  fstat(options: FstatOptions) {
    const event = "fstat"
    try {
      const stats = this.fstatSync(options)
      invokeSuccess(event, options, { stats })
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  fstatSync(options: Omit<FstatOptions, "success" | "fail" | "complete">) {
    const event = "fstatSync"

    const { fd } = options

    if (!fd || !isString(fd)) {
      throw new Error(`${event}:fail ${errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "fd")}`)
    }

    const { stats, errMsg } = globalThis.__FileSystem.fstat(fd)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }

    const res = stats as Stats
    res.isFile = () => {
      return (stats.mode & S_IFREG) === S_IFREG
    }
    res.isDirectory = () => {
      return (stats.mode & S_IFDIR) === S_IFDIR
    }
    return res
  }

  ftruncate(options: FtruncateOptions) {
    const event = "fstat"
    try {
      this.ftruncateSync(options)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  ftruncateSync(options: Omit<FtruncateOptions, "success" | "fail" | "complete">) {
    const event = "ftruncateSync"

    const { fd, length = 0 } = options

    if (!fd || !isString(fd)) {
      throw new Error(`${event}:fail ${errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "fd")}`)
    }

    const { errMsg } = globalThis.__FileSystem.ftruncate(fd, length)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  read(options: ReadOptions) {
    const event = "read"
    try {
      const res = this.readSync(options)
      invokeSuccess(event, options, res)
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  readSync(options: Omit<ReadOptions, "success" | "fail" | "complete">) {
    const event = "readSync"

    const { fd, arrayBuffer, offset = 0, length = 0, position = 0 } = options

    if (!fd || !isString(fd)) {
      throw new Error(`${event}:fail ${errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "fd")}`)
    }

    if (!isArrayBuffer(arrayBuffer)) {
      throw new Error(`${event}:fail arrayBuffer must be an ArrayBuffer`)
    }

    const { bytesRead, errMsg } = globalThis.__FileSystem.read(
      fd,
      arrayBuffer,
      offset,
      length,
      position
    )
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }

    return {
      bytesRead,
      arrayBuffer
    }
  }

  write(options: WriteOptions) {
    const event = "write"
    try {
      const res = this.writeSync(options)
      invokeSuccess(event, options, res)
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }

  writeSync(options: Omit<WriteOptions, "success" | "fail" | "complete">) {
    const event = "writeSync"

    const { fd, data, encoding = "utf8", offset = 0, length = 0, position = 0 } = options

    if (!fd || !isString(fd)) {
      throw new Error(`${event}:fail ${errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "fd")}`)
    }

    if (!isString(data) && !isArrayBuffer(data)) {
      throw new Error(`${event}:fail arrayBuffer must be a string or ArrayBuffer`)
    }

    const noHyphenEncoding = formatAndValidEncoding(event, encoding)

    const { bytesWritten, errMsg } = globalThis.__FileSystem.write(
      fd,
      data,
      offset,
      length,
      position,
      noHyphenEncoding
    )
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }

    return {
      bytesWritten
    }
  }

  getFileInfo(options: Omit<GetFileInfoOptions, "digestAlgorithm">) {
    getFileInfo(options)
  }

  getSavedFileList(options: GetSavedFileListOptions) {
    getSavedFileList(options)
  }

  removeSavedFile(options: RemoveSavedFileOptions) {
    removeSavedFile(options)
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

function formatAndValidEncoding(event: string, encoding?: Encoding) {
  if (!encoding) {
    throw new Error(`${event}:fail unknown encoding`)
  }

  const noHyphenEncoding = encoding.replaceAll("-", "")
  if (
    !["ascii", "base64", "hex", "utf16le", "utf8", "latin1", "ucs2", "binary"].includes(
      noHyphenEncoding
    )
  ) {
    throw new Error(`${event}:fail unknown encoding: ${encoding}`)
  }
  return noHyphenEncoding
}
