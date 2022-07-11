import type { Plugin, ResolvedConfig } from "vite"
import colors from "picocolors"
import path from "path"
import { getDirAllFiles, getFileHash, getAppId, zip } from "./utils"
import { runWebSocketServer, createMessage, createFileMessage, Client } from "./webSocket"
import fg from "fast-glob"

let firstBuildFinished = false

let serviceVersion = Date.now()

const prevFileHash = new Map()

const clients: Client[] = []

let config: ResolvedConfig

interface DevSDKOptions {
  root: string
}

interface DevLaunchOptions {
  page: string
  query?: string
}

export interface Options {
  host?: string | boolean
  port?: number
  devSDK?: DevSDKOptions
  launchOptions?: DevLaunchOptions
}

export default function vitePluginEvokerDevtools(options: Options = {}): Plugin {
  createWebSocketServer(options)

  return {
    name: "vite:evoker-devtools",

    enforce: "post",

    configResolved(reslovedConfig) {
      config = reslovedConfig
    },

    async buildStart(this, _) {
      if (options.devSDK?.root) {
        const fp = path.resolve(options.devSDK.root, "packages/*/dist/*")
        const files = await fg(fp)
        files.forEach(f => {
          this.addWatchFile(f)
        })
      }
    },

    closeBundle() {
      firstBuildFinished = true
      serviceVersion = Date.now()
      update(clients)
    }
  }
}

function send(data: any, clients: Client[]) {
  data && clients.filter(x => x.readyState === 1).forEach(x => x.send(data))
}

let options: Options
/**
 * 启动 WebSocket Server
 * @param options
 */
function createWebSocketServer(opts: Options) {
  options = opts
  runWebSocketServer({
    host: options.host,
    port: options.port,
    onConnect: client => {
      clients.push(client)
      checkClientVersion(client)
    },
    onDisconnect: client => {
      const i = clients.findIndex(x => x._id === client._id)
      if (i > -1) {
        clients.splice(i, 1)
      }
    },
    onRecv: (client, message) => {
      if (message === "ping") {
        send("pong", [client])
      } else {
        try {
          const obj = JSON.parse(message)
          obj && onRecv(client, obj)
        } catch {}
      }
    }
  })
}

function onRecv(client: Client, message: { event: string; data: Record<string, any> }) {
  switch (message.event) {
    case "version":
      const { version: clientVersion } = message.data
      if (clientVersion !== serviceVersion.toString()) {
        if (firstBuildFinished) {
          prevFileHash.clear()
          client && update([client])
        }
      }
      break
  }
}

/**
 * 查询客户端是否需要更新
 */
function checkClientVersion(client: Client) {
  const appId = getAppId()
  const message = JSON.stringify({ appId, wsId: client._id })
  const data = createMessage("--CHECKVERSION--", message)
  send(data, [client])
}

/**
 * 向客户端发送需要更新的文件
 */
function update(clients: Client[]) {
  return new Promise(async () => {
    const appId = getAppId()

    config.logger.info(colors.cyan(`\ncheck ${appId} update...`))

    const updateFiles: string[] = []

    let sdkFiles: string[] = []
    if (options.devSDK) {
      sdkFiles = loadSDKFiles(options.devSDK.root)
      sdkFiles = getNeedUpdateFiles(sdkFiles)
      updateFiles.push(...sdkFiles)
    }

    let appFiles = loadAppFiles()
    appFiles = getNeedUpdateFiles(appFiles)
    updateFiles.push(...appFiles)

    if (updateFiles.length) {
      config.logger.info(`\n${colors.green(`✓`)} ${updateFiles.length} files required update.\n`)

      const files: string[] = []

      let sdk: Buffer | null = null
      if (sdkFiles.length) {
        sdk = await zip("dist/", sdkFiles)
        files.push("sdk")
      }

      let app: Buffer | null = null
      if (appFiles.length) {
        app = await zip(config.build.outDir + "/", appFiles)
        files.push("app")
      }

      if (files.length && clients.length) {
        const message = JSON.stringify({
          appId,
          files,
          version: serviceVersion.toString(),
          launchOptions: options.launchOptions
        })

        const data = createMessage("--UPDATE--", message)
        send(data, clients)

        if (sdk) {
          const data = createFileMessage(appId, "sdk", sdk)
          send(data, clients)
        }

        if (app) {
          const data = createFileMessage(appId, "app", app)
          send(data, clients)
        }

        config.logger.info(colors.cyan(`push ${appId} update files to client completed.\n`))
      }
    } else {
      config.logger.info(colors.cyan("\nno update"))
    }
    return Promise.resolve()
  })
}

/**
 * 读取基础库文件
 * @returns
 */
function loadSDKFiles(root: string) {
  const pkgs = ["evoker", "webview", "vue"]
  const include: Record<string, string[]> = {
    evoker: ["evoker.global.js"],
    webview: ["webview.global.js", "evoker-built-in.css", "index.html"],
    vue: ["vue.runtime.global.js"]
  }

  const allFiles: string[] = []
  const pkgsDir = path.resolve(root)
  pkgs.forEach(pkg => {
    const pkgDir = path.resolve(pkgsDir, `packages/${pkg}/dist`)
    const files = include[pkg].map(file => path.join(pkgDir, file))
    allFiles.push(...files)
  })
  return allFiles
}

/**
 * 读取 App 文件
 * @returns
 */
function loadAppFiles() {
  const files = getDirAllFiles(path.resolve("dist/"))
  return files.filter(file => path.extname(file) !== "d.ts")
}

/**
 * 过滤出需要更新的文件
 * @param files
 * @returns
 */
function getNeedUpdateFiles(files: string[]) {
  const changedFiles: string[] = []
  for (const filepath of files) {
    const hash = getFileHash(filepath)
    if (hash) {
      if (prevFileHash.get(filepath) !== hash) {
        prevFileHash.set(filepath, hash)
        changedFiles.push(filepath)
      }
    }
  }
  return changedFiles
}
