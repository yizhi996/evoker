import { resolve } from "path"
import { createViteConfig } from "../../scripts/utils"

const pkg = require(resolve(__dirname, `package.json`))

export default createViteConfig({
  target: "vite-plugin",
  rollupOptions: {
    external: [...Object.keys(pkg.dependencies), "fs", "zlib", "os", "crypto", "path"]
  }
})
