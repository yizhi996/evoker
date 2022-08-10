import type { ESBuildOptions, Plugin, ResolvedConfig } from "vite"
import fs from "fs"
import { parseVueRequest } from "@vitejs/plugin-vue"
import path from "path"
import os from "os"
import { transform, TransformOptions, formatMessages } from "esbuild"
import colors from "picocolors"
import { getHash } from "../utils"
import { outputAppConfig } from "./app"
import { PageInfo } from "./router"

const cssLangs = `\\.(css|less|sass|scss|styl|stylus|pcss|postcss)($|\\?)`
const cssLangRE = new RegExp(cssLangs)
const isCSSRequest = request => cssLangRE.test(request)

export default function vitePluginEvokerCSS(): Plugin {
  const styles: Map<string, string> = new Map<string, string>()

  let config: ResolvedConfig

  let input: string

  return {
    name: "vite:evoker-css",

    configResolved: _config => {
      config = _config
      input = (config.build.lib && config.build.lib.entry) || ""
      if (!input) {
        throw new Error("lib entry cannot be empty.")
      }
    },

    load(id) {
      if (id === input) {
        const inject = `import config from "./app.json";globalThis.__Config = config;`
        const og = fs.readFileSync(id, "utf-8")
        return inject + og
      }
    },

    transform(css, id, opts) {
      if (!isCSSRequest(id)) {
        return
      }
      styles.set(id, css)
      return
    },

    renderChunk(code, chunk, opts) {
      const mainCSSName = chunk.facadeModuleId
        ? normalizePath(path.relative(config.root, chunk.facadeModuleId))
        : chunk.name

      const ids = Object.keys(chunk.modules)

      const chunkCSS = new Map<string, string>()

      for (const id of ids) {
        if (styles.has(id)) {
          const css = styles.get(id)
          const { filename, query } = parseVueRequest(id)
          const chunkName = query.vue ? filename : mainCSSName
          const CSS = chunkCSS.get(chunkName) || ""
          chunkCSS.set(chunkName, CSS + css)
        }
      }

      chunkCSS.forEach(async (css, fileName) => {
        css = await finalizeCss(css, true, config)

        const cssAssetName = normalizePath(path.relative(config.root, fileName))
        const cssFileName = ensureFileExt(cssAssetName, ".css")
        const assetFileNames = path.posix.join(config.build.assetsDir, "[name].[hash][extname]")
        const dest = assetFileNamesToFileName(assetFileNames, cssFileName, getHash(css))

        const parsed = path.parse(normalizePath(path.relative("src", cssAssetName)))
        const pagePath = path.join(parsed.dir, parsed.name)
        const i = (outputAppConfig.pages as PageInfo[]).findIndex(p => p.path === pagePath)
        if (i > -1) {
          outputAppConfig.pages[i].css = dest
        }

        this.emitFile({
          name: cssFileName,
          fileName: dest,
          type: "asset",
          source: css
        })
      })

      return null
    }
  }
}

const isWindows = os.platform() === "win32"

function slash(p: string): string {
  return p.replace(/\\/g, "/")
}

function normalizePath(id: string): string {
  return path.posix.normalize(isWindows ? slash(id) : id)
}

function ensureFileExt(name: string, ext: string) {
  return normalizePath(path.format({ ...path.parse(name), base: undefined, ext }))
}

function assetFileNamesToFileName(
  assetFileNames: string,
  file: string,
  contentHash: string
): string {
  const basename = path.basename(file)

  // placeholders for `assetFileNames`
  // `hash` is slightly different from the rollup's one
  const extname = path.extname(basename)
  const ext = extname.substring(1)
  const name = basename.slice(0, -extname.length)

  const fileName = assetFileNames.replace(/\[\w+\]/g, (placeholder: string): string => {
    switch (placeholder) {
      case "[ext]":
        return ext

      case "[hash]":
        return contentHash

      case "[extname]":
        return extname

      case "[name]":
        return name
    }
    throw new Error(`invalid placeholder ${placeholder} in assetFileNames "${assetFileNames}"`)
  })

  return fileName
}

async function finalizeCss(css: string, minify: boolean, config: ResolvedConfig) {
  if (minify && config.build.minify) {
    css = await minifyCSS(css, config)
  }
  return css
}

async function minifyCSS(css: string, config: ResolvedConfig) {
  try {
    const { code, warnings } = await transform(css, {
      loader: "css",
      target: config.build.cssTarget || undefined,
      ...resolveEsbuildMinifyOptions(config.esbuild || {})
    })
    if (warnings.length) {
      const msgs = await formatMessages(warnings, { kind: "warning" })
      config.logger.warn(colors.yellow(`warnings when minifying css:\n${msgs.join("\n")}`))
    }
    return code
  } catch (e: any) {
    if (e.errors) {
      const msgs = await formatMessages(e.errors, { kind: "error" })
      e.frame = "\n" + msgs.join("\n")
      e.loc = e.errors[0].location
    }
    throw e
  }
}

function resolveEsbuildMinifyOptions(options: ESBuildOptions): TransformOptions {
  const base: TransformOptions = {
    logLevel: options.logLevel,
    logLimit: options.logLimit,
    logOverride: options.logOverride
  }

  if (
    options.minifyIdentifiers != null ||
    options.minifySyntax != null ||
    options.minifyWhitespace != null
  ) {
    return {
      ...base,
      minifyIdentifiers: options.minifyIdentifiers ?? true,
      minifySyntax: options.minifySyntax ?? true,
      minifyWhitespace: options.minifyWhitespace ?? true
    }
  } else {
    return { ...base, minify: true }
  }
}
