// @ts-check
const args = require("minimist")(process.argv.slice(2))
const execa = require("execa")
const { getPkgDir } = require("./utils")

const target = args._[0]

async function test(package) {
  await execa("vitest", ["--config", "vite.config.ts"], {
    stdio: "inherit",
    cwd: getPkgDir(package)
  })
}

test(target)
