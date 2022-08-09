// @ts-check
import { build } from "vite"
import { resolve } from "path"
import minimist from "minimist"
import { allPakcages, packageDirectory } from "./utils.js"

const args = minimist(process.argv.slice(2))

const target = args._[0]

const targets = allPakcages().filter(p => p !== "create-evoker" && p !== "vue")

if (!target) {
  targets.forEach(buildTarget)
} else {
  buildTarget(target)
}

async function buildTarget(target) {
  const pkgDir = packageDirectory(target)
  return await build({
    configFile: resolve(pkgDir, "vite.config.ts"),
    root: pkgDir,
    mode: "development",
    build: {
      minify: false,
      watch: {}
    }
  })
}
