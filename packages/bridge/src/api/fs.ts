import { GeneralCallbackResult, invokeSuccess, invokeFailure } from "../async"
import { isString } from "@vue/shared"
import { ErrorCodes, errorMessage } from "../errors"
import { EKFILE_SCHEME, EKFILE_TMP, USER_DATA_PATH } from "./const"
import { isArrayBuffer } from "@evoker/shared"
import { getFileInfo, getSavedFileList, removeSavedFile } from "./file"
import type { GetFileInfoOptions, GetSavedFileListOptions, RemoveSavedFileOptions } from "./file"

const S_IFREG = 32768

const S_IFDIR = 16384

let globalFileSystemManager: FileSystemManager | undefined

/** 获取全局唯一的文件管理器 */
export function getFileSystemManager() {
  if (!globalFileSystemManager) {
    globalFileSystemManager = new FileSystemManager()
  }
  return globalFileSystemManager
}

interface AccessOptions {
  /** 要判断是否存在的文件/目录路径 (本地路径) */
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
  /** 创建的目录路径 (本地路径) */
  dirPath: string
  /** 是否在递归创建该目录的上级目录后再创建该目录。
   * 如果对应的上级目录已经存在，则不创建该上级目录。
   * 如 dirPath 为 a/b/c/d 且 recursive 为 true，
   * 将创建 a 目录，再在 a 目录下创建 b 目录，以此类推直至创建 a/b/c 目录下的 d 目录 */
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
  /** 要删除的目录路径 (本地路径) */
  dirPath: string
  /** 是否递归删除目录。如果为 true，则删除该目录和该目录下的所有子目录以及文件 */
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
  /** 要读取的目录路径 (本地路径) */
  dirPath: string
  /** 接口调用成功的回调函数 */
  success?: ReaddirSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ReaddirFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ReaddirCompleteCallback
}

interface ReaddirSuccessCallbackResult {
  /** 指定目录下的文件名数组 */
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
  /** 要读取的文件的路径 (本地路径) */
  filePath: string
  /** 指定读取文件的字符编码，如果不传 encoding，则以 ArrayBuffer 格式读取文件的二进制内容 */
  encoding?: Encoding
  /** 从文件指定位置开始读，如果不指定，则从文件头开始读。
   * 读取的范围应该是左闭右开区间 [position, position+length)。有效范围：[0, fileLength - 1]。
   * 单位：byte */
  position?: number
  /** 指定文件的长度，如果不指定，则读到文件末尾。有效范围：[1, fileLength]。单位：byte */
  length?: number
  /** 接口调用成功的回调函数 */
  success?: ReadFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ReadFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ReadFileCompleteCallback
}

interface ReadFileSuccessCallbackResult {
  /** 文件内容 */
  data: string | ArrayBuffer
}

type ReadFileSuccessCallback = (res: ReadFileSuccessCallbackResult) => void

type ReadFileFailCallback = (res: GeneralCallbackResult) => void

type ReadFileCompleteCallback = (res: GeneralCallbackResult) => void

interface WriteFileOptions {
  /** 要写入的文件路径 (本地路径) */
  filePath: string
  /** 要写入的文本或二进制数据 */
  data: string | ArrayBuffer
  /** 指定写入文件的字符编码 */
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
  /** 源文件路径，支持本地路径 */
  oldPath: string
  /** 新文件路径，支持本地路径 */
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

interface CopyFileOptions {
  /** 源文件路径，支持本地路径 */
  srcPath: string
  /** 目标文件路径，支持本地路径 */
  destPath: string
  /** 接口调用成功的回调函数 */
  success?: CopyFileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CopyFileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CopyFileCompleteCallback
}

type CopyFileSuccessCallback = (res: GeneralCallbackResult) => void

type CopyFileFailCallback = (res: GeneralCallbackResult) => void

type CopyFileCompleteCallback = (res: GeneralCallbackResult) => void

interface AppendFileOptions {
  /** 要追加内容的文件路径 (本地路径) */
  filePath: string
  /** 要追加的文本或二进制数据 */
  data: string | ArrayBuffer
  /** 指定写入文件的字符编码 */
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
  /** 要删除的文件路径 (本地路径) */
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
  /** 文件/目录路径 (本地路径) */
  path: string
  /** 是否递归获取目录下的每个文件的 Stats 信息 */
  recursive?: boolean
  /** 接口调用成功的回调函数 */
  success?: StatSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: StatFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: StatCompleteCallback
}

interface StatSuccessCallbackResult {
  /** 当 recursive 为 false 时，res.stats 是一个 Stats 对象。
   * 当 recursive 为 true 且 path 是一个目录的路径时，res.stats 是一个 Array，
   * 数组的每一项是一个对象，每个对象包含 path 和 stats */
  stats: Stats | { path: string; stats: Stats }[]
}

type StatSuccessCallback = (res: StatSuccessCallbackResult) => void

type StatFailCallback = (res: GeneralCallbackResult) => void

type StatCompleteCallback = (res: GeneralCallbackResult) => void

interface SaveFileOptions {
  /** 临时存储文件路径 (本地路径) */
  tempFilePath: string
  /** 要存储的文件路径 (本地路径) */
  filePath?: string
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

type Flag = "a" | "ax" | "a+" | "ax+" | "as" | "as+" | "r" | "r+" | "w" | "wx" | "w+" | "wx+"

interface OpenOptions {
  /** 文件路径 (本地路径) */
  filePath: string
  /** 文件系统标志，默认值: 'r'
   *
   * 可选值：
   * - a: 打开文件用于追加。 如果文件不存在，则创建该文件
   * - ax: 类似于 'a'，但如果路径存在，则失败
   * - a+: 打开文件用于读取和追加。 如果文件不存在，则创建该文件
   * - ax+: 类似于 'a+'，但如果路径存在，则失败
   * - as: 打开文件用于追加（在同步模式中）。 如果文件不存在，则创建该文件
   * - as+: 打开文件用于读取和追加（在同步模式中）。 如果文件不存在，则创建该文件
   * - r: 打开文件用于读取。 如果文件不存在，则会发生异常
   * - r+: 打开文件用于读取和写入。 如果文件不存在，则会发生异常
   * - w: 打开文件用于写入。 如果文件不存在则创建文件，如果文件存在则截断文件
   * - wx: 类似于 'w'，但如果路径存在，则失败
   * - w+: 打开文件用于读取和写入。 如果文件不存在则创建文件，如果文件存在则截断文件
   * - wx+: 类似于 'w+'，但如果路径存在，则失败
   */
  flag: Flag
  /** 接口调用成功的回调函数 */
  success?: OpenSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: OpenFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: OpenCompleteCallback
}

interface OpenSuccessCallbackResult {
  /** 文件描述符 */
  fd: string
}

type OpenSuccessCallback = (res: OpenSuccessCallbackResult) => void

type OpenFailCallback = (res: GeneralCallbackResult) => void

type OpenCompleteCallback = (res: GeneralCallbackResult) => void

interface CloseOptions {
  /** 需要被关闭的文件描述符。fd 通过 FileSystemManager.open 接口获得 */
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
  /** 文件描述符。通过 FileSystemManager.open 接口获得 */
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
  /** 文件描述符。通过 FileSystemManager.open 接口获得 */
  fd: string
  /** 截断位置，默认0。
   * 如果 length 小于文件长度（单位：字节），
   * 则只有前面 length 个字节会保留在文件中，
   * 其余内容会被删除；如果 length 大于文件长度，
   * 则会对其进行扩展，并且扩展部分将填充空字节（'\0'） */
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
  /** 文件描述符。通过 FileSystemManager.open 接口获得 */
  fd: string
  /** 数据写入的缓冲区，必须是 ArrayBuffer 实例 */
  arrayBuffer: ArrayBuffer
  /** 缓冲区中的写入偏移量，默认0 */
  offset?: number
  /** 要从文件中读取的字节数，默认0 */
  length?: number
  /** 文件读取的起始位置，如不传或传 null，则会从当前文件指针的位置读取。
   * 如果 position 是正整数，则文件指针位置会保持不变并从 position 读取文件 */
  position?: number
  /** 接口调用成功的回调函数 */
  success?: ReadSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ReadFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ReadCompleteCallback
}

interface ReadResult {
  /** 实际读取的字节数 */
  bytesRead: number
  /** 被写入的缓存区的对象，即接口入参的 arrayBuffer */
  arrayBuffer: ArrayBuffer
}

type ReadSuccessCallback = (res: ReadResult) => void

type ReadFailCallback = (res: GeneralCallbackResult) => void

type ReadCompleteCallback = (res: GeneralCallbackResult) => void

interface WriteOptions {
  /** 文件描述符。通过 FileSystemManager.open 接口获得 */
  fd: string
  /** 写入的内容，类型为 string 或 ArrayBuffer */
  data: string | ArrayBuffer
  /** 只在 data 类型是 String 时有效，指定写入文件的字符编码，默认为 utf8 */
  encoding?: Encoding
  /** 只在 data 类型是 ArrayBuffer 时有效，决定 arrayBuffe 中要被写入的部位，
   * 即 arrayBuffer 中的索引，默认0 */
  offset?: number
  /** 只在 data 类型是 ArrayBuffer 时有效，指定要写入的字节数，
   * 默认为 arrayBuffer 从0开始偏移 offset 个字节后剩余的字节数 */
  length?: number
  /** 指定文件开头的偏移量，即数据要被写入的位置。
   * 当 position 不传或者传入非 Number 类型的值时，数据会被写入当前指针所在位置 */
  position?: number
  /** 接口调用成功的回调函数 */
  success?: WriteSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: WriteFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: WriteCompleteCallback
}

interface WriteResult {
  /** 实际被写入到文件中的字节数（注意，被写入的字节数不一定与被写入的字符串字符数相同） */
  bytesWritten: number
}

type WriteSuccessCallback = (res: WriteResult) => void

type WriteFailCallback = (res: GeneralCallbackResult) => void

type WriteCompleteCallback = (res: GeneralCallbackResult) => void

/** 文件管理器，可通过 ek.getFileSystemManager 获取 */
class FileSystemManager {
  /** 判断文件/目录是否存在 */
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

  /** 判断文件/目录是否存在的同步方法 */
  accessSync(
    /** 要判断是否存在的文件/目录路径 (本地路径) */
    path: string
  ) {
    const event = "accessSync"

    validFilePath(event, path, "path", EKFILE_SCHEME)

    const { errMsg } = globalThis.__FileSystem.access(path)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  /** 创建目录 */
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

  /** 创建目录的同步方法 */
  mkdirSync(
    /** 创建的目录路径 (本地路径) */
    dirPath: string,
    /** 是否在递归创建该目录的上级目录后再创建该目录。
     * 如果对应的上级目录已经存在，则不创建该上级目录。
     * 如 dirPath 为 a/b/c/d 且 recursive 为 true，
     * 将创建 a 目录，再在 a 目录下创建 b 目录，以此类推直至创建 a/b/c 目录下的 d 目录 */
    recursive: boolean = false
  ) {
    const event = "mkdirSync"

    validFilePath(event, dirPath, "dirPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__FileSystem.mkdir(dirPath, recursive)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  /** 删除目录 */
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

  /** 删除目录的同步方法 */
  rmdirSync(
    /** 要删除的目录路径 (本地路径) */
    dirPath: string,
    /** 是否递归删除目录。如果为 true，则删除该目录和该目录下的所有子目录以及文件 */
    recursive: boolean = false
  ) {
    const event = "rmdirSync"

    validFilePath(event, dirPath, "dirPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__FileSystem.rmdir(dirPath, recursive)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  /** 读取目录内文件列表 */
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

  /** 读取目录内文件列表的同步方法 */
  readdirSync(
    /** 要读取的目录路径 (本地路径) */
    dirPath: string
  ) {
    const event = "readdirSync"

    validFilePath(event, dirPath, "dirPath", USER_DATA_PATH)

    const { files, errMsg } = globalThis.__FileSystem.readdir(dirPath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    return files
  }

  /** 读取本地文件内容 */
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

  /** 读取本地文件内容的同步方法  */
  readFileSync(
    /** 要读取的文件的路径 (本地路径) */
    filePath: string,
    /** 指定读取文件的字符编码，如果不传 encoding，则以 ArrayBuffer 格式读取文件的二进制内容 */
    encoding?: Encoding,
    /** 从文件指定位置开始读，如果不指定，则从文件头开始读。
     * 读取的范围应该是左闭右开区间 [position, position+length)。有效范围：[0, fileLength - 1]。
     * 单位：byte */
    position?: number,
    /** 指定文件的长度，如果不指定，则读到文件末尾。有效范围：[1, fileLength]。单位：byte */
    length?: number
  ) {
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

  /** 写文件 */
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

  /** 写文件的同步方法 */
  writeFileSync(
    /** 要写入的文件路径 (本地路径) */
    filePath: string,
    /** 要写入的文本或二进制数据 */
    data: string | ArrayBuffer,
    /** 指定写入文件的字符编码 */
    encoding: Encoding = "utf8"
  ) {
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

  /** 重命名文件。可以把文件从 oldPath 移动到 newPath */
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

  /** 重命名文件的同步方法。可以把文件从 oldPath 移动到 newPath */
  renameSync(
    /** 源文件路径，支持本地路径 */
    oldPath: string,
    /** 新文件路径，支持本地路径 */
    newPath: string
  ) {
    const event = "renameSync"

    validFilePath(event, oldPath, "oldPath", USER_DATA_PATH)

    validFilePath(event, newPath, "newPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__FileSystem.rename(oldPath, newPath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  /** 复制文件 */
  copyFile(options: CopyFileOptions) {
    const event = "copyFile"
    try {
      this.copyFileSync(options.srcPath, options.destPath)
      invokeSuccess(event, options, {})
    } catch (error) {
      if (error instanceof Error) {
        invokeFailure(event, options, error.message.replace(`${event}Sync:fail `, ""))
      }
    }
  }
  /** 复制文件的同步方法 */
  copyFileSync(
    /** 源文件路径，支持本地路径 */
    srcPath: string,
    /** 目标文件路径，支持本地路径 */
    destPath: string
  ) {
    const event = "copyFileSync"

    validFilePath(event, srcPath, "srcPath", USER_DATA_PATH)

    validFilePath(event, destPath, "destPath", USER_DATA_PATH)

    const { errMsg } = globalThis.__FileSystem.copyFile(srcPath, destPath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  /** 在文件结尾追加内容 */
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

  /** 在文件结尾追加内容的同步方法 */
  appendFileSync(
    /** 要追加内容的文件路径 (本地路径) */
    filePath: string,
    /** 要追加的文本或二进制数据 */
    data: string | ArrayBuffer,
    /** 指定写入文件的字符编码 */
    encoding: Encoding = "utf8"
  ) {
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

  /** 删除文件 */
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

  /** 删除文件的同步方法 */
  unlinkSync(
    /** 要删除的文件路径 (本地路径) */
    filePath: string
  ) {
    const event = "unlinkSync"

    validFilePath(event, filePath, "filePath", USER_DATA_PATH)

    const { errMsg } = globalThis.__FileSystem.unlink(filePath)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
  }

  /** 获取文件 Stats 对象 */
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

  /** 同步获取文件 Stats 对象 */
  statSync(
    /** 文件/目录路径 (本地路径) */
    path: string,
    /** 是否递归获取目录下的每个文件的 Stats 信息 */
    recursive: boolean = false
  ) {
    const event = "statSync"

    validFilePath(event, path, "path", USER_DATA_PATH)

    const { stats, errMsg } = globalThis.__FileSystem.stat(path, recursive)
    if (errMsg) {
      throw new Error(`${event}:fail ${errMsg}`)
    }
    return stats as Stats | { path: string; stats: Stats }[]
  }

  /** 保存临时文件到本地。此接口会移动临时文件，因此调用成功后，tempFilePath 将不可用 */
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

  /** 保存临时文件到本地。此接口会移动临时文件，因此调用成功后，tempFilePath 将不可用 */
  saveFileSync(
    /** 临时存储文件路径 (本地路径) */
    tempFilePath: string,
    /** 要存储的文件路径 (本地路径) */
    filePath: string = ""
  ) {
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

  /** 打开文件，返回文件描述符 */
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

  /** 打开文件，返回文件描述符 */
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

  /** 关闭文件 */
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

  /** 关闭文件 */
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

  /** 获取文件的状态信息 */
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

  /** 获取文件的状态信息 */
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

  /** 对文件内容进行截断操作 */
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

  /** 对文件内容进行截断操作 */
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

  /** 读文件 */
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

  /** 读文件 */
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

  /** 写入文件 */
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

  /** 写入文件 */
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

  /** 获取文件信息 */
  getFileInfo(options: Omit<GetFileInfoOptions, "digestAlgorithm">) {
    getFileInfo(options)
  }

  /** 获取该小程序下已保存的本地缓存文件列表 */
  getSavedFileList(options: GetSavedFileListOptions) {
    getSavedFileList(options)
  }

  /** 删除本地缓存文件 */
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
