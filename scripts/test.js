// @ts-check
import minimist from "minimist"
import { execa } from "execa"
import { packageDirectory } from "./utils.js"

const args = minimist(process.argv.slice(2))

const target = args._[0]

async function test(pkg) {
  await execa("vitest", ["--config", "vite.config.ts"], {
    stdio: "inherit",
    cwd: packageDirectory(pkg)
  })
}

test(target)
