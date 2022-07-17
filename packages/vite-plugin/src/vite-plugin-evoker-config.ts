import type { Plugin, ResolvedConfig } from "vite"
import { resolve } from "path"
import fs from "fs"
import { Options } from "./index"

let config: ResolvedConfig

let input: string

const entryFiles = ["main.ts", "index.ts", "main.js", "index.js"]

function getEntry() {
  for (const file of entryFiles) {
    const fp = resolve(`src/${file}`)
    if (fs.existsSync(fp)) {
      return fp
    }
  }
  throw new Error("lib entry cannot be empty")
}

export default function vitePluginEvokerConfig(options: Options = {}): Plugin {
  return {
    name: "vite:evoker-config",
    enforce: "pre",

    config: config => {
      const DEV = config.mode === "development"

      return {
        build: {
          minify: DEV ? false : "esbuild",
          assetsInlineLimit: 0,
          lib: {
            entry: (options.build!.lib && options.build!.lib.entry) || getEntry(),
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
        }
      }
    },

    configResolved: _config => {
      config = _config
      input = (config.build.lib && config.build.lib.entry) || ""
    },

    load(id) {
      if (id === input) {
        const inject = `import config from "./app.json";globalThis.__Config = config;`
        const og = fs.readFileSync(id, "utf-8")
        return inject + og
      }
      return null
    }
  }
}
