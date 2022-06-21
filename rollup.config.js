// @ts-check
import path from "path"
import ts from "rollup-plugin-typescript2"
import json from "@rollup/plugin-json"
import commonjs from "@rollup/plugin-commonjs"

if (!process.env.TARGET) {
  throw new Error("TARGET package must be specified via --environment flag.")
}

const masterVersion = require("./package.json").version
const packagesDir = path.resolve(__dirname, "packages")
const packageDir = path.resolve(packagesDir, process.env.TARGET)
const resolve = p => path.resolve(packageDir, p)
const pkg = require(resolve(`package.json`))
const packageOptions = pkg.buildOptions || {}
const name = packageOptions.filename || path.basename(packageDir)

let hasTSChecked = false

const outputConfigs = {
  "esm-bundler": {
    file: resolve(`dist/${name}.esm-bundler.js`),
    format: `es`
  },
  "esm-browser": {
    file: resolve(`dist/${name}.esm-browser.js`),
    format: `es`
  },
  cjs: {
    file: resolve(`dist/${name}.cjs.js`),
    format: `cjs`
  },
  global: {
    file: resolve(`dist/${name}.global.js`),
    format: `iife`
  },
  // runtime-only builds, for main "vue" package only
  "esm-bundler-runtime": {
    file: resolve(`dist/${name}.runtime.esm-bundler.js`),
    format: `es`
  },
  "esm-browser-runtime": {
    file: resolve(`dist/${name}.runtime.esm-browser.js`),
    format: "es"
  },
  "global-runtime": {
    file: resolve(`dist/${name}.runtime.global.js`),
    format: "iife"
  }
}

const packageFormats = packageOptions.formats || ["esm-bundler", "cjs"]

export default packageFormats.map(format => {
  return createConfig(format, outputConfigs[format])
})

function createConfig(format, output, plugins = []) {
  if (!output) {
    console.log(require("chalk").yellow(`invalid format: "${format}"`))
    process.exit(1)
  }

  const isProductionBuild = process.env.__DEV__ === "false" || /\.prod\.js$/.test(output.file)
  const isBundlerESMBuild = /esm-bundler/.test(format)
  const isServerRenderer = name === "server-renderer"
  const isNodeBuild = format === "cjs"
  const isGlobalBuild = /global/.test(format)
  const isCompatBuild = !!packageOptions.compat

  output.exports = "named"
  output.sourcemap = !!process.env.SOURCE_MAP
  output.externalLiveBindings = false

  if (isGlobalBuild) {
    output.name = packageOptions.name
  }

  const shouldEmitDeclarations = pkg.types && process.env.TYPES != null && !hasTSChecked

  const tsPlugin = ts({
    check: process.env.NODE_ENV === "production" && !hasTSChecked,
    tsconfig: path.resolve(__dirname, "tsconfig.json"),
    cacheRoot: path.resolve(__dirname, "node_modules/.rts2_cache"),
    tsconfigOverride: {
      compilerOptions: {
        target: isNodeBuild ? "es2020" : "es2016",
        sourceMap: output.sourcemap,
        declaration: shouldEmitDeclarations,
        declarationMap: shouldEmitDeclarations
      },
      exclude: ["**/__tests__", "test-dts"]
    }
  })

  hasTSChecked = true

  let entryFile = `src/index.ts`

  let external = []

  if (name === "nzoth" && isGlobalBuild) {
    external.push("vue")
    output.globals = { vue: "Vue" }
    plugins.push(...[commonjs(), require("@rollup/plugin-node-resolve").nodeResolve()])
  } else {
    external.push(
      ...Object.keys(pkg.dependencies || {}),
      ...Object.keys(pkg.peerDependencies || {})
    )

    if (name === "vite-plugin") {
      external.push(...["ws", "zlib", "path", "fs", "os", "crypto"])
    }
  }

  console.log(external)

  return {
    input: resolve(entryFile),
    external,
    plugins: [
      json({
        namedExports: false
      }),
      tsPlugin,
      ...plugins
    ],
    output,
    onwarn: (msg, warn) => {
      if (!/Circular/.test(msg)) {
        warn(msg)
      }
    },
    treeshake: {
      moduleSideEffects: false
    }
  }
}
