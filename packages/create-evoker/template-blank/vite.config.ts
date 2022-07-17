import { defineConfig } from "vite"
import evoker from "@evoker/vite-plugin"

// https://vitejs.dev/config/
export default defineConfig(() => {
  return {
    plugins: [
      evoker({
        devtools: {
          host: true
        }
      })
    ]
  }
})
