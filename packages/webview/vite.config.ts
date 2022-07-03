import vue from "@vitejs/plugin-vue"
import copy from "rollup-plugin-copy"
import { resolve } from "path"
import jsx from "@vitejs/plugin-vue-jsx"
import { getViteConfig } from "../../scripts/utils"

export default getViteConfig(
  "webview",
  {
    output: {
      assetFileNames: asset => {
        if (asset.name === "style.css") {
          return "evoker-built-in.css"
        }
        return asset.name
      }
    }
  },
  [
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
      isCustomElement: tag => tag.startsWith("ev-")
    })
  ]
)
