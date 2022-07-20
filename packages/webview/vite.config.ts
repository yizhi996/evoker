import vue from "@vitejs/plugin-vue"
import copy from "rollup-plugin-copy"
import { resolve } from "path"
import jsx from "@vitejs/plugin-vue-jsx"
import { createViteConfig } from "../../scripts/utils"

export default createViteConfig({
  target: "webview",
  vite: {
    resolve: {
      alias: {
        "@evoker/shared": resolve(__dirname, "../shared/src/index.ts"),
        "@evoker/bridge": resolve(__dirname, "../bridge/src/index.ts")
      }
    },
    build: {
      rollupOptions: {
        external: [],
        output: {
          assetFileNames: asset => {
            if (asset.name === "style.css") {
              return "evoker-built-in.css"
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
        ]
      }),
      jsx({
        isCustomElement: tag => tag.startsWith("ek-")
      })
    ],
    test: {
      globals: true,
      environment: "jsdom",
      transformMode: {
        web: [/.[tj]sx$/]
      }
    }
  }
})
