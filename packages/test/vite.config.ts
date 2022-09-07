import { defineConfig } from "vite"
import { resolve } from "path"

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    define: {
      "process.env.NODE_ENV": JSON.stringify(mode)
    },
    server: {
      host: true
    },
    evoker: {
      dev: {
        devSDK: {
          root: resolve(__dirname, "../..")
        },
        
      }
    }
  }
})
