// @ts-check
const { resolve, basename } = require("path")
const execa = require("execa")
const fs = require("fs")
const { gzipSync } = require("zlib")
const colors = require("picocolors")

const args = require("minimist")(process.argv.slice(2))

const target = args._[0]

const rmdir = path => fs.rmSync(path, { recursive: true, force: true })

function allTargets() {
  return fs.readdirSync("packages").filter(package => {
    return (
      package !== "vue" &&
      fs.statSync(`packages/${package}`).isDirectory() &&
      require(`../packages/${package}/package.json`)
    )
  })
}

async function buildAll(targets) {
  const promises = targets.map(target => {
    return build(target)
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

function checkAllTargetSize(targets) {
  targets.forEach(checkProdFileSize)
}

function checkProdFileSize(target) {
  const pkgDir = resolve(`packages/${target}`)
  const pkg = require(resolve(`${pkgDir}/package.json`))
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
    const targets = allTargets()
    await buildAll(targets)
    checkAllTargetSize(targets)
  } else {
    await build(target)
    checkProdFileSize(target)
  }
})()
