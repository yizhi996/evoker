import type { Plugin, ResolvedConfig } from "vite"
import fs from "fs"
import { resolve } from "path"

let outputAppConfig: {
  [x: string]: any
} = {}

export { outputAppConfig }

export default function vitePluginEvokerConfig(): Plugin {
  let config: ResolvedConfig

  let input: string

  return {
    name: "vite:evoker-app",

    enforce: "pre",

    configResolved: _config => {
      config = _config
      if (config.build.lib) {
        input = resolve(config.root, config.build.lib.entry)
      } else {
        throw new Error("lib entry cannot be empty.")
      }
    },

    writeBundle() {
      const cfg = JSON.stringify(outputAppConfig, null, 4)
      fs.writeFileSync(resolve(config.build.outDir, "app.json"), cfg, "utf-8")
    }
  }
}
