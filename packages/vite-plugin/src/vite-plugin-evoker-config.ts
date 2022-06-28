import type { Plugin, BuildOptions, ResolvedConfig } from "vite"
import { resolve } from "path"
import fs from "fs"

let config: ResolvedConfig

export default function vitePluginEvokerConfig(options: BuildOptions = {}): Plugin {
  return {
    name: "vite:evoker-config",
    enforce: "pre",

    config: config => ({
      build: {
        minify: config.mode === "development" ? false : "terser",
        assetsInlineLimit: 0,
        lib: {
          entry: resolve("src/main.ts"),
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
        }
      }
    }),

    configResolved: _config => {
      config = _config
    },

    load(id) {
      if (id === config.build.rollupOptions.input) {
        const inject = `import config from "./app.json";globalThis.__Config = config;`
        const og = fs.readFileSync(id, "utf-8")
        return inject + og
      }
      return null
    }
  }
}
