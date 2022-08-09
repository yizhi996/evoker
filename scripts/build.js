// @ts-check
import { resolve, basename, dirname } from "path"
import { execa } from "execa"
import fs from "fs"
import { gzipSync } from "zlib"
import colors from "picocolors"
import { allPakcages } from "./utils.js"
import minimist from "minimist"
import { fileURLToPath } from "url"
import pLimit from "p-limit"
import os from "os"

const limit = pLimit(os.cpus().length)

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const args = minimist(process.argv.slice(2))

const target = args._[0]

const targets = allPakcages().filter(p => p !== "vue" && p !== "create-evoker")

const rmdir = path => fs.rmSync(path, { recursive: true, force: true })

async function buildAll() {
  const promises = targets.map(target => {
    return limit(() => build(target))
  })
  return Promise.all(promises)
}

async function build(target) {
  const pkgDir = resolve(`packages/${target}`)

  rmdir(resolve(`${pkgDir}/dist`))

  const types = target !== "webview"

  await execa(
    "rollup",
    [
      "-c",
      "rollup.config.js",
      "--environment",
      [`NODE_ENV:production`, `TARGET:${target}`, `TYPES:${types}`, `PROD_ONLY:true`].join(",")
    ],
    { stdio: "inherit" }
  )

  rmdir(`${pkgDir}/dist/packages`)
}

const toKiB = n => {
  return (n / 1024).toFixed(2) + " KiB"
}

function checkAllTargetSize() {
  targets.forEach(checkProdFileSize)
}

function checkProdFileSize(target) {
  const pkgDir = resolve(`packages/${target}`)
  const pkg = JSON.parse(fs.readFileSync(resolve(`${pkgDir}/package.json`), { encoding: "utf-8" }))
  if (!pkg.buildOptions) {
    return
  }
  const formats = pkg.buildOptions.formats || []
  if (!formats.includes("global")) {
    return
  }
  checkFileSize(resolve(`${pkgDir}/dist/${target}.global.prod.js`))
}

function checkFileSize(filePath) {
  if (!fs.existsSync(filePath)) {
    return
  }
  const file = fs.readFileSync(filePath)
  const gzip = gzipSync(file)
  console.log()
  console.log(
    colors.bold(
      colors.cyan(
        `${basename(filePath)}   ${colors.gray(
          `${toKiB(file.length)} / gzip: ${toKiB(gzip.length)}`
        )}`
      )
    )
  )
}

;(async function () {
  rmdir(resolve(__dirname, "../node_modules/.rts2_cache"))
  if (!target) {
    await buildAll()
    checkAllTargetSize()
  } else {
    await build(target)
    checkProdFileSize(target)
  }
})()
