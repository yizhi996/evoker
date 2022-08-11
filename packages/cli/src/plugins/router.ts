import type { Plugin, ResolvedConfig } from "vite"
import { getAppConfig } from "../utils"
import color from "picocolors"
import { extend, isString } from "@vue/shared"
import fs from "fs"
import { resolve } from "path"
import { outputAppConfig } from "./app"

export interface PageInfo {
  path: string
  style: any
  css?: string
}

type Page = string | PageInfo

const getPath = (page: Page) => (isString(page) ? page : page.path)

export default function vitePluginEvokerRouter(): Plugin {
  let config: ResolvedConfig

  let input: string

  let prevPages: Page[] = []

  return {
    name: "vite:evoker-router",

    configResolved: _config => {
      config = _config
      if (config.build.lib) {
        input = resolve(config.root, config.build.lib.entry)
      } else {
        throw new Error("lib entry cannot be empty.")
      }
    },

    transform(code: string, id: string) {
      if (id !== input) {
        return
      }

      const appConfig = getAppConfig()

      extend(outputAppConfig, appConfig)

      outputAppConfig.pages = []

      const imports: string[] = []
      const defines: string[] = []

      const newPages: Page[] = []
      for (let i = 0; i < appConfig.pages.length; i++) {
        const page = appConfig.pages[i] as Page
        const name = `evoker_$${i}`
        const path = getPath(page)

        const ext = getPageFileExt(path)
        if (ext) {
          imports.push(`import ${name} from './${path}.${ext}'`)
          defines.push(`defineRouter('${path}', ${name})`)
          newPages.push(page)
          outputAppConfig.pages.push({ path: path, style: isString(page) ? {} : page.style })
        }
      }

      const addPages = newPages.filter(x => {
        const path = getPath(x)
        return prevPages.findIndex(y => getPath(y) === path) === -1
      })

      const delPages = prevPages.filter(x => {
        const path = getPath(x)
        return newPages.findIndex(y => getPath(y) === path) === -1
      })

      if (addPages.length || delPages.length) {
        console.log()
        for (const page of addPages) {
          const path = getPath(page)
          console.log(`loaded page: ${color.cyan(path)} `)
        }

        prevPages = prevPages.concat(addPages)

        for (const page of delPages) {
          const path = getPath(page)
          console.log(`remove page: ${color.cyan(path)}`)
          const i = prevPages.findIndex(y => getPath(y) === path)
          if (i > -1) {
            prevPages.splice(i, 1)
          }
        }
      }

      const nextLine = "\n"

      let defineRouter = `import { defineRouter } from 'evoker'${nextLine}`
      defineRouter += imports.join(nextLine) + nextLine
      defineRouter += defines.join(nextLine) + nextLine
      return {
        code: defineRouter + code
      }
    }
  }
}

const exts = ["vue", "tsx", "jsx"]

function getPageFileExt(path: string) {
  for (let i = 0; i < exts.length; i++) {
    const ext = exts[i]
    if (fs.existsSync(resolve("src", `${path}.${ext}`))) {
      return ext
    }
  }
}
