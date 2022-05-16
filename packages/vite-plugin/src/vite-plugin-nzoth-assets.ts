import type { Plugin, ResolvedConfig } from "vite"
import path from "path"
import os from "os"
import fs from "fs"
import type { PluginContext } from "rollup"
import { getAppConfig } from "./utils"

let config: ResolvedConfig

const cache = new Map<string, string>()

export default function vitePluginNZothAssets(): Plugin {
  return {
    name: "vite:nzoth-assets",

    enforce: "pre",

    configResolved(reslovedConfig) {
      config = reslovedConfig
    },

    async load(id) {
      if (id.startsWith("\0")) {
        // Rollup convention, this id should be handled by the
        // plugin that marked it with \0
        return
      }

      const file = cleanUrl(id)
      if (!config.assetsInclude(file)) {
        return
      }

      id = id.replace(urlRE, "$1").replace(/[\?&]$/, "")

      const url = await fileToUrl(id, config, this)
      return `export default ${JSON.stringify(url)}`
    },

    buildEnd() {
      const appConfig = getAppConfig()
      if (appConfig.tabBar && appConfig.tabBar.list) {
        const tabBars = appConfig.tabBar.list
        tabBars.forEach((info: any) => {
          emitTabBarIcon(info.iconPath, this)
          emitTabBarIcon(info.selectedIconPath, this)
        })
      }
      cache.clear()
    }
  }
}

const rawRE = /(\?|&)raw(?:&|$)/
const urlRE = /(\?|&)url(?:&|$)/

const queryRE = /\?.*$/s
const hashRE = /#.*$/s

const cleanUrl = (url: string): string => url.replace(hashRE, "").replace(queryRE, "")

const isWindows = os.platform() === "win32"

function normalizePath(id: string): string {
  return path.posix.normalize(isWindows ? slash(id) : id)
}

function slash(p: string): string {
  return p.replace(/\\/g, "/")
}

export const FS_PREFIX = `/@fs/`

function emitTabBarIcon(iconPath: string, pluginContext: PluginContext) {
  if (!cache.has(iconPath)) {
    const dir = path.posix.dirname(config.build.rollupOptions.input!.toString())

    const file = cleanUrl(path.posix.join(dir, iconPath))

    const content = fs.readFileSync(file)

    const name = normalizePath(path.relative(config.root, file))

    const fileName = iconPath

    pluginContext.emitFile({
      name,
      fileName,
      type: "asset",
      source: content
    })

    cache.set(iconPath, "")
  }
}

function fileToUrl(id: string, config: ResolvedConfig, pluginContext: PluginContext) {
  let url = cache.get(id)
  if (url) {
    return url
  }

  let rtn: string
  if (id.startsWith(config.root)) {
    // in project root, infer short public path
    rtn = "/" + path.posix.relative(config.root, id)
  } else {
    // outside of project root, use absolute fs path
    // (this is special handled by the serve static middleware
    rtn = path.posix.join(FS_PREFIX + id)
  }
  url = config.base + rtn.replace(/^\//, "")

  const file = cleanUrl(id)

  const dir = path.posix.dirname(config.build.rollupOptions.input!.toString())

  const fileName = path.posix.relative(dir, file)

  const content = fs.readFileSync(file)
  const name = normalizePath(path.relative(config.root, file))

  pluginContext.emitFile({
    name,
    fileName,
    type: "asset",
    source: content
  })
  cache.set(id, url)
  return url
}
