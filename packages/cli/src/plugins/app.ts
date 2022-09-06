import type { Plugin, ResolvedConfig } from "vite"
import fs from "fs"
import { resolve } from "path"

let outputAppConfig: {
  [x: string]: any
} = {}

export { outputAppConfig }

export function resetOutputAppConfig() {
  outputAppConfig = {}
}

export default function vitePluginEvokerConfig(): Plugin {
  let config: ResolvedConfig

  return {
    name: "vite:evoker-app",

    enforce: "pre",

    configResolved: _config => {
      config = _config
      if (!config.build.lib || !config.build.lib.entry) {
        throw new Error("lib entry cannot be empty.")
      }
    },

    transform() {
      this.addWatchFile(resolve("src/app.json"))
    },

    writeBundle() {
      const cfg = JSON.stringify(outputAppConfig)
      fs.writeFileSync(resolve(config.build.outDir, "app.json"), cfg, "utf-8")
    }
  }
}
