// @ts-check
const { resolve } = require("path")
const execa = require("execa")
const fs = require("fs-extra")

const args = require("minimist")(process.argv.slice(2))

const target = args._[0] || "nzoth"

const pkgDir = resolve(`packages/${target}`)

const pkg = require(resolve(pkgDir, "package.json"))

async function webviewBuild() {
  return await execa("vite", ["build"], { stdio: "inherit", cwd: pkgDir })
}

async function rollupBuild() {
  const env = (pkg.buildOptions && pkg.buildOptions.env) || "production"
  return await execa(
    "rollup",
    [
      "-c",
      "rollup.config.js",
      "--environment",
      [`NODE_ENV:${env}`, `TARGET:${target}`, `TYPES:true`, `PROD_ONLY:true`]
        .filter(Boolean)
        .join(",")
    ],
    { stdio: "inherit" }
  )
}

async function rollupDTS() {
  return await execa(
    "rollup",
    ["-c", "rollup.config.dts.js", "--environment", `TARGET:${target}`],
    { stdio: "inherit" }
  )
}

async function buildTarget() {
  await fs.remove(resolve(__dirname, "../node_modules/.rts2_cache"))

  if (target === "webview") {
    await webviewBuild()
    await rollupDTS()
  } else {
    await rollupBuild()
    await rollupDTS()
  }

  await fs.remove(`${pkgDir}/dist/packages`)
}

buildTarget()
