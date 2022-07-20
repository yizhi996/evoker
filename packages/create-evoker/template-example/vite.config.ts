import { defineConfig } from "vite"
import { resolve } from "path"

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    define: {
      "process.env.NODE_ENV": JSON.stringify(mode)
    },
    resolve: {
      alias: {
        "@": resolve(__dirname, "./src")
      }
    },
    server: {
      host: true
    }
  }
})
