import { Plugin, ResolvedConfig } from "vite"
import { resolve } from "path"
import fs from "fs"
import archiver from "archiver"
import colors from "picocolors"
import { getRelativeFilePath } from "./utils"

let config: ResolvedConfig

export default function vitePluginEvokerPack(): Plugin {
  return {
    apply: "build",

    enforce: "post",

    name: "vite:evoker-pack",

    configResolved(reslovedConfig) {
      config = reslovedConfig
    },

    closeBundle() {
      pack()
    }
  }
}

function pack() {
  const root = resolve(config.build.outDir)

  const fileName = `app-service.evpkg`

  const output = resolve(root, fileName)

  const stream = fs.createWriteStream(output)

  const archive = archiver.create("zip", { zlib: { level: 9 } })

  let totalSize = 0

  stream.on("finish", () => {
    console.log(colors.green("✓"), "packed")
    const stat = fs.statSync(output)

    console.log(
      colors.gray(
        `${config.build.outDir}/${colors.cyan(
          `${fileName}   ${colors.gray(`${toKiB(totalSize)} / pkg: ${toKiB(stat.size)}`)}`
        )}`
      )
    )
  })

  const toKiB = (n: number) => {
    return (n / 1024).toFixed(2) + " KiB"
  }

  console.log("packing...")

  archive
    .on("error", err => {
      console.error("pack failed, err: ", err)
    })
    .pipe(stream)

  const files: string[] = []

  const append = (filePath: string, file: string) => {
    if (fs.statSync(filePath).isDirectory()) {
      appendDirectory(filePath)
    } else {
      archive.file(filePath, { name: file })
      files.push(file)

      const stat = fs.statSync(filePath)
      totalSize += stat.size
    }
  }

  const appendDirectory = (dir: string) => {
    fs.readdirSync(dir).forEach(file => {
      const fp = resolve(dir, file)
      append(fp, getRelativeFilePath(root, fp))
    })
  }

  fs.readdirSync(root)
    .filter(file => file !== fileName)
    .forEach(file => {
      append(resolve(root, file), file)
    })

  archive.append(files.join("\n"), { name: "files" })

  archive.finalize()
}
