import { build as viteBuild, mergeConfig, loadConfigFromFile, resolveConfig } from "vite"
import type { InlineConfig, ResolvedConfig } from "vite"
import { resolve } from "path"
import fs from "fs"
import router from "./plugins/router"
import { vue } from "./vue"
import pack from "./pack"
import app from "./plugins/app"
import dev from "./plugins/dev"
import css from "./plugins/css"
import copy from "rollup-plugin-copy"
import type { Options as DevOptions } from "./plugins/dev"
import type { Options as VueOptions } from "@vitejs/plugin-vue"

const entryFiles = ["main.ts", "index.ts", "app.ts", "main.js", "index.js", "app.js"]

function getEntry() {
  for (const file of entryFiles) {
    const fp = resolve(`src/${file}`)
    if (fs.existsSync(fp)) {
      return fp
    }
  }
  return ""
}

interface EvokerConfig {
  vue?: VueOptions
  dev?: DevOptions
}

export async function build(mode: string = "development") {
  const DEV = mode === "development"

  const defaultConfig = (await resolveConfig({ mode }, "build")) as ResolvedConfig & {
    evoker: EvokerConfig
  }

  const evokerConfig = defaultConfig.evoker || {}

  const outDir = defaultConfig.build.outDir

  let config: InlineConfig = {
    build: {
      minify: DEV ? false : "esbuild",
      assetsInlineLimit: 0,
      lib: {
        entry: getEntry(),
        name: "AppService",
        fileName: () => "app-service.js",
        formats: ["iife"]
      },
      rollupOptions: {
        external: ["evoker", "vue"],
        output: {
          globals: {
            evoker: "Evoker",
            vue: "Vue"
          }
        }
      },
      watch: DEV ? {} : null
    },
    plugins: [
      vue(evokerConfig.vue || {}),
      app(),
      css(),
      router(),
      DEV ? dev(evokerConfig.dev || {}) : pack(),
      copy({
        targets: [
          // { src: resolve("src/app.json"), dest: resolve(outDir) },
          {
            src: resolve(`src/${defaultConfig.build.assetsDir}`),
            dest: resolve(outDir)
          }
        ],
        hook: "writeBundle"
      })
    ]
  }

  const loadResult = await loadConfigFromFile({ mode, command: "build" })
  if (loadResult) {
    config = mergeConfig(config, loadResult.config)
  }

  return await viteBuild(config)
}
