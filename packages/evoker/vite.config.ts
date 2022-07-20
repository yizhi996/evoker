import { createViteConfig } from "../../scripts/utils"

export default createViteConfig({
  target: "evoker",
  vite: {
    build: {
      rollupOptions: {
        external: ["vue"],
        output: {
          globals: {
            vue: "Vue"
          }
        }
      }
    }
  }
})
