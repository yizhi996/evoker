import { defineConfig } from "vite"
import evoker from "@evoker/vite-plugin"

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    define: {
      "process.env.NODE_ENV": JSON.stringify(mode)
    },
    plugins: [
      evoker({
        devtools: {
          host: true
        }
      })
    ]
  }
})
