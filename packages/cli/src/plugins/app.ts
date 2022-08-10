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
      input = (config.build.lib && config.build.lib.entry) || ""
      if (!input) {
        throw new Error("lib entry cannot be empty.")
      }
    },

    load(id) {
      if (id === input) {
        const inject = `import config from "./app.json";globalThis.__Config = config;`
        const og = fs.readFileSync(id, "utf-8")
        return inject + og
      }
    },

    writeBundle() {
      const cfg = JSON.stringify(outputAppConfig, null, 4)
      fs.writeFileSync(resolve(config.build.outDir, "app.json"), cfg, "utf-8")
    }
  }
}
