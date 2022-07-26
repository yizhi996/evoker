import { createViteConfig } from "../../scripts/utils"

export default createViteConfig({
  target: "devtools",
  vite: { build: { rollupOptions: { external: [] } } }
})
