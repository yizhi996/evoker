import type { Plugin, BuildOptions, ResolvedConfig } from "vite"
import { resolve } from "path"
import fs from "fs"

let config: ResolvedConfig

export default function vitePluginNZothConfig(options: BuildOptions = {}): Plugin {
  return {
    name: "vite:nzoth-config",
    enforce: "pre",

    config: config => ({
      build: {
        minify: config.mode === "development" ? false : "terser",
        assetsInlineLimit: 0,
        lib: {
          entry: resolve("src/main.ts"),
          name: "NZAppService",
          fileName: () => "app-service.js",
          formats: ["iife"]
        },
        rollupOptions: {
          external: ["nzoth", "vue"],
          output: {
            globals: {
              nzoth: "NZoth",
              vue: "Vue"
            }
          }
        }
      }
    }),

    configResolved: _config => {
      config = _config
    },

    load(id) {
      if (id === config.build.rollupOptions.input) {
        const inject = `import config from "./app.json";globalThis.__NZConfig = config;`
        const og = fs.readFileSync(id, "utf-8")
        return inject + og
      }
      return null
    }
  }
}
