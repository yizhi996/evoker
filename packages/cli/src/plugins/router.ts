import type { Plugin } from "vite"
import { getAppConfig } from "../utils"
import color from "picocolors"
import { extend, isString } from "@vue/shared"
import fs from "fs"
import { resolve } from "path"
import { outputAppConfig } from "./app"

export interface PageInfo {
  path: string
  css?: string
}

type Page = string | PageInfo

const getPath = (page: Page) => (isString(page) ? page : page.path)

let prevPages: Page[] = []

export default function vitePluginEvokerRouter(): Plugin {
  return {
    name: "vite:evoker-router",

    transform(code: string, id: string) {
      if (!id.endsWith("app.json")) {
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
          outputAppConfig.pages.push({ path: path })
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

      code += `import { defineRouter } from 'evoker'${nextLine}`
      code += imports.join(nextLine) + nextLine
      code += defines.join(nextLine) + nextLine
      return {
        code
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
