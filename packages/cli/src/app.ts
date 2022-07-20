import type { Plugin, ResolvedConfig } from "vite"
import fs from "fs"

let config: ResolvedConfig

let input: string

export default function vitePluginEvokerConfig(): Plugin {
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
    }
  }
}
