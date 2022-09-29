import type { Plugin, ResolvedConfig } from "vite"
import colors from "picocolors"
import path from "path"
import { getDirAllFiles, getFileHash, getAppId, zip, log } from "../utils"
import { createWebSocketServer, createMessage, createFileMessage } from "../webSocket"
import chokidar from "chokidar"
import debounce from "lodash.debounce"

import { WebSocket } from "ws"

let firstBuildFinished = false

let serviceVersion = Date.now()

const prevFileHash = new Map()

let config: ResolvedConfig

interface DevSDKOptions {
  root: string
}

interface DevLaunchOptions {
  page: string
}

export interface Options {
  devSDK?: DevSDKOptions
  launchOptions?: DevLaunchOptions
}

let options: Options

let ws: ReturnType<typeof createWebSocketServer>

const debouncedUpdate = debounce(updateToAllClients, 200)

export default function vitePluginEvokerDevtools(_options: Options = {}): Plugin {
  options = _options
  return {
    name: "vite:evoker-devtools",

    enforce: "post",

    configResolved(reslovedConfig) {
      config = reslovedConfig

      ws = createWebSocketServer({
        host: config.server.host,
        port: config.server.port,
        onConnect: client => {
          sendAppInfo(client)
        },
        onRecv(client, message) {
          try {
            const obj = JSON.parse(message)
            obj && onRecv(client, obj)
          } catch {}
        }
      })

      if (options.devSDK?.root) {
        const watcher = chokidar.watch("file", {
          ignored: /(^|[\/\\])\../,
          persistent: true
        })
        watcher.on("add", debouncedUpdate)

        const files = loadSDKFiles(options.devSDK.root)
        files.forEach(file => {
          watcher.add(file)
        })
      }
    },

    closeBundle: {
      sequential: true,
      order: "post",
      handler() {
        firstBuildFinished = true
        serviceVersion = Date.now()
        update(ws.clients())
        log(`address: ${ws.address()}`)
      }
    }
  }
}

function send(data: any, clients: WebSocket[]) {
  data && clients.filter(x => x.readyState === WebSocket.OPEN).forEach(x => x.send(data))
}

const enum Events {
  VERSION = "version"
}

function onRecv(client: WebSocket, message: { event: Events; data: Record<string, any> }) {
  switch (message.event) {
    case Events.VERSION:
      const { version } = message.data
      if (version !== serviceVersion.toString()) {
        if (firstBuildFinished) {
          prevFileHash.clear()
          client && update([client])
        }
      }
      break
  }
}

const enum Methods {
  APP_INFO = "--APPINFO--",
  UPDATE = "--UPDATE--"
}

function sendAppInfo(client: WebSocket) {
  const appId = getAppId()
  const message = JSON.stringify({
    appId,
    version: serviceVersion.toString(),
    envVersion: "develop"
  })
  const data = createMessage(Methods.APP_INFO, message)
  send(data, [client])
}

function updateToAllClients() {
  if (!firstBuildFinished) {
    return
  }
  setTimeout(() => {
    update(ws.clients())
  }, 100)
}

/**
 * 向客户端发送需要更新的文件
 */
function update(clients: WebSocket[]) {
  return new Promise(async () => {
    const appId = getAppId()

    log(`check ${appId} update...\n`)

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
      log(`${colors.green(`✓`)} ${updateFiles.length} files need to update.\n`)

      const files: string[] = []

      let sdk: Buffer | null = null
      if (sdkFiles.length) {
        try {
          sdk = await zip("dist/", sdkFiles)
          files.push("sdk")
        } catch (e) {
          console.error(e)
        }
      }

      let app: Buffer | null = null
      if (appFiles.length) {
        try {
          app = await zip(config.build.outDir + "/", appFiles)
          files.push("app")
        } catch (e) {
          console.error(e)
        }
      }

      if (files.length && clients.length && (app || sdk)) {
        const version = serviceVersion.toString()
        const message = JSON.stringify({
          appId,
          files,
          version: version,
          launchOptions: options.launchOptions
        })

        const data = createMessage(Methods.UPDATE, message)
        send(data, clients)

        if (sdk) {
          const data = createFileMessage(appId, version, "sdk", sdk)
          send(data, clients)
        }

        if (app) {
          const data = createFileMessage(appId, version, "app", app)
          send(data, clients)
        }

        log(`push ${appId} update files completed.\n`)
      }
    } else {
      log("no update")
    }
    return Promise.resolve()
  })
}

/**
 * 读取基础库文件
 * @returns
 */
function loadSDKFiles(root: string) {
  const pkgs = ["evoker", "webview", "vue", "devtools"]
  const include: Record<string, string[]> = {
    evoker: ["evoker.global.js"],
    webview: ["webview.global.js", "evoker-built-in.css", "index.html"],
    vue: ["vue.runtime.global.js"],
    devtools: ["devtools.global.js"]
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
