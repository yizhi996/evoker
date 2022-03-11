import type { Plugin, BuildOptions } from "vite"
import { resolve } from "path"

export default function vitePluginNZothConfig(
  options: BuildOptions = {}
): Plugin {
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
    })
  }
}
