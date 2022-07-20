import minimist from "minimist"
import { build } from "./build"

const args = minimist(process.argv.slice(2))

const command = args._[0]

const enum Commands {
  DEV = "dev",
  BUILD = "build",
  PACK = "pack"
}

async function main() {
  switch (command) {
    case Commands.DEV:
      await build()
      break
    case Commands.BUILD:
      await build("production")
      break
    case Commands.PACK:
      break
    default:
      console.error("command is invalid.")
      break
  }
}

main()
