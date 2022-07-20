import { resolve } from "path"
import { createViteConfig } from "../../scripts/utils"
import builtinModules from "builtin-modules"

const pkg = require(resolve(__dirname, `package.json`))

export default createViteConfig({
  target: "cli",
  vite: {
    build: {
      rollupOptions: {
        external: [...Object.keys(pkg.dependencies), ...builtinModules]
      }
    }
  }
})
