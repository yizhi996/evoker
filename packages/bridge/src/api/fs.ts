import { GeneralCallbackResult, invokeSuccess, invokeFailure } from "../async"
import { isArray, isString } from "@vue/shared"
import { ErrorCodes, errorMessage } from "../errors"
import { EKFILE_SCHEME, USER_DATA_PATH } from "./const"
import { isArrayBuffer } from "@evoker/shared"

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

interface UnlinkOptions {
  filePath: string
  success?: UnlinkSuccessCallback
  fail?: UnlinkFailCallback
  complete?: UnlinkCompleteCallback
}

type UnlinkSuccessCallback = (res: GeneralCallbackResult) => void

type UnlinkFailCallback = (res: GeneralCallbackResult) => void

type UnlinkCompleteCallback = (res: GeneralCallbackResult) => void

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

    const { errMsg } = globalThis.__AppServiceNativeSDK.fileSystemManager.unlink(filePath)
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
