// @ts-check
const { resolve } = require("path")
const execa = require("execa")
const fs = require("fs-extra")
const colors = require("picocolors")

const args = require("minimist")(process.argv.slice(2))

const target = args._[0] || "nzoth"

const pkgDir = resolve(`packages/${target}`)

const pkg = require(resolve(pkgDir, "package.json"))

async function buildWebview() {
  console.log(colors.bold(colors.cyan(`generating ${target} ts declaration`)))
  await execa("tsc", ["--declarationDir", "dist", "--declaration", "--target", "es2016"], {
    stdio: "inherit",
    cwd: pkgDir
  })
  console.log(colors.bold(colors.green(`generated ${target} ts declaration`)))

  return await rollupBuild(false)
}

async function rollupBuild(types = true) {
  const env = (pkg.buildOptions && pkg.buildOptions.env) || "production"
  return await execa(
    "rollup",
    [
      "-c",
      "rollup.config.js",
      "--environment",
      [`NODE_ENV:${env}`, `TARGET:${target}`, `TYPES:${types}`, `PROD_ONLY:true`]
        .filter(Boolean)
        .join(",")
    ],
    { stdio: "inherit" }
  )
}

async function build() {
  await fs.remove(resolve(__dirname, "../node_modules/.rts2_cache"))

  if (target === "webview") {
    await buildWebview()
  } else {
    await rollupBuild()
  }

  await fs.remove(`${pkgDir}/dist/packages`)
}

build()
