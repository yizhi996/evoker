import { defineConfig } from "vite"
import vue from "@vitejs/plugin-vue"
import copy from "rollup-plugin-copy"
import { resolve } from "path"
import jsx from "@vitejs/plugin-vue-jsx"

const pkg = require(resolve(__dirname, "package.json"))

// https://vitejs.dev/config/
export default defineConfig(() => {
  return {
    build: {
      lib: {
        entry: resolve(__dirname, "src/index.ts"),
        name: pkg.buildOptions?.name,
        fileName: foramt => "webview.global.js",
        formats: ["iife"]
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
      vue(),
      copy({
        targets: [
          {
            src: resolve(__dirname, "src/index.html"),
            dest: resolve(__dirname, "dist/")
          }
        ],
        hook: "writeBundle"
      }),
      jsx({
        isCustomElement: tag => tag.startsWith("nz-")
      })
    ]
  }
})
