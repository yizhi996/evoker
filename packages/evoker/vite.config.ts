import { createViteConfig } from "../../scripts/utils"

export default createViteConfig({
  target: "evoker",
  rollupOptions: {
    external: ["vue"],
    output: {
      globals: {
        vue: "Vue"
      }
    }
  }
})
