import { resolve } from "path"
import { getViteConfig } from "../../scripts/utils"

const pkg = require(resolve(__dirname, `package.json`))

export default getViteConfig("vite-plugin", {
  external: [...Object.keys(pkg.dependencies), "fs", "zlib", "os", "crypto", "path"]
})
