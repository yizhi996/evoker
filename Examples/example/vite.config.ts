import { defineConfig } from "vite"
import nzoth from "@nzoth/vite-plugin"
import styleImport, { VantResolve } from "vite-plugin-style-import"
import { resolve } from "path"

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    resolve: {
      alias: {
        "@": resolve(__dirname, "./src")
      }
    },
    plugins: [
      nzoth({
        mode,
        devtools: {
          host: true,
          devSDK: { root: resolve(__dirname, "../../packages") }
        }
      }),
      styleImport({
        resolves: [VantResolve()]
      })
    ]
  }
})
