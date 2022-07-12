import vue from "@vitejs/plugin-vue"
import copy from "rollup-plugin-copy"
import { resolve } from "path"
import jsx from "@vitejs/plugin-vue-jsx"
import { createViteConfig } from "../../scripts/utils"

export default createViteConfig({
  target: "webview",
  resolve: {
    alias: {
      "@evoker/shared": resolve("../shared/src/index.ts"),
      "@evoker/bridge": resolve("../bridge/src/index.ts")
    }
  },
  rollupOptions: {
    output: {
      assetFileNames: asset => {
        if (asset.name === "style.css") {
          return "evoker-built-in.css"
        }
        return asset.name
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
})
