// @ts-check
const { build } = require("vite")
const { resolve } = require("path")
const { allPakcages, getPkgDir } = require("./utils")
const args = require("minimist")(process.argv.slice(2))

const target = args._[0]

const targets = allPakcages().filter(p => p !== "create-evoker" && p !== "vue")

if (!target) {
  targets.forEach(buildTarget)
} else {
  buildTarget(target)
}

async function buildTarget(target) {
  const pkgDir = getPkgDir(target)

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
