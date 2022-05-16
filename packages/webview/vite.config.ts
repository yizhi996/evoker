import { defineConfig } from "vite"
import vue from "@vitejs/plugin-vue"
import copy from "rollup-plugin-copy"
import { isHTMLTag, isSVGTag } from "@nzoth/shared"
import { resolve } from "path"

const pkg = require(resolve(__dirname, "package.json"))

// https://vitejs.dev/config/
export default defineConfig(() => {
  return {
    build: {
      lib: {
        entry: resolve(__dirname, "src/index.ts"),
        name: pkg.buildOptions?.name,
        fileName: foramt => `webview.${foramt === "iife" ? "global" : "esm"}.js`,
        formats: ["iife", "es"]
      },
      rollupOptions: {
        output: {
          assetFileNames: asset => {
            if (asset.name === "style.css") {
              return "nzoth-built-in.css"
            }
            return asset.name
          }
        }
      }
    },
    plugins: [
      vue({
        template: {
          compilerOptions: {
            isNativeTag: tag => isHTMLTag(tag) || isSVGTag(tag) || tag.startsWith("nz-")
          }
        }
      }),
      copy({
        targets: [
          {
            src: resolve(__dirname, "src/index.html"),
            dest: resolve(__dirname, "dist/")
          }
        ],
        hook: "writeBundle"
      })
    ]
  }
})
