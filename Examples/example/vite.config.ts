import { defineConfig } from "vite"
import evoker from "@evoker/vite-plugin"
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
      evoker({
        mode,
        devtools: {
          host: true
        }
      }),
      styleImport({
        resolves: [VantResolve()]
      })
    ]
  }
})
