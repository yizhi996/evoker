// @ts-check
const { build } = require("vite")
const { resolve } = require("path")
const fs = require("fs-extra")
const ts = require("rollup-plugin-typescript2")

const args = require("minimist")(process.argv.slice(2))

const target = args._[0] || "nzoth"

const pkgDir = resolve(__dirname, `../packages/${target}`)

const pkg = require(resolve(pkgDir, "package.json"))

const configFile = resolve(pkgDir, "vite.config.ts")

const tsPlugin = ts({
  check: false,
  tsconfig: resolve(__dirname, "../tsconfig.json"),
  tsconfigOverride: {
    compilerOptions: {
      declaration: true,
      declarationMap: true
    }
  }
})

;(async () => {
  await build({
    configFile,
    root: pkgDir,
    build: {
      minify: "terser"
    },
    plugins: [tsPlugin]
  })

  // from vue/core
  const { Extractor, ExtractorConfig } = require("@microsoft/api-extractor")

  const extractorConfigPath = resolve(pkgDir, `api-extractor.json`)
  const extractorConfig =
    ExtractorConfig.loadFileAndPrepare(extractorConfigPath)
  const extractorResult = Extractor.invoke(extractorConfig, {
    localBuild: true,
    showVerboseMessages: true
  })

  if (extractorResult.succeeded) {
    console.log("api-extractor success")

    const typesDir = resolve(pkgDir, "types")
    if (await fs.exists(typesDir)) {
      const dtsPath = resolve(pkgDir, pkg.types)
      const existing = await fs.readFile(dtsPath, "utf-8")
      const typeFiles = await fs.readdir(typesDir)
      const toAdd = await Promise.all(
        typeFiles.map(file => {
          return fs.readFile(resolve(typesDir, file), "utf-8")
        })
      )
      await fs.writeFile(dtsPath, existing + "\n" + toAdd.join("\n"))
      console.log(`API Extractor completed successfully.`)
    }
  }
  await fs.remove(`${pkgDir}/dist/packages`)
})()
