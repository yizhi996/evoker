import { defineConfig } from "vite"
import evoker from "@evoker/vite-plugin"

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    plugins: [
      evoker({
        mode,
        devtools: {
          host: true
        }
      })
    ]
  }
})
