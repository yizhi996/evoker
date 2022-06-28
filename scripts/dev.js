// @ts-check
const { build } = require("vite")
const { resolve } = require("path")

const args = require("minimist")(process.argv.slice(2))

const target = args._[0] || "evoker"

const pkgDir = resolve(__dirname, `../packages/${target}`)
const configFile = resolve(pkgDir, "vite.config.ts")

build({
  configFile,
  root: pkgDir,
  mode: "development",
  build: {
    minify: false,
    watch: {}
  }
})
