// @ts-check
import path from "path"
import ts from "rollup-plugin-typescript2"
import commonjs from "@rollup/plugin-commonjs"
import { DEFAULT_EXTENSIONS } from "@babel/core"
import nodeResolve from "@rollup/plugin-node-resolve"
import replace from "@rollup/plugin-replace"
import dts from "rollup-plugin-dts"
import { terser } from "rollup-plugin-terser"

if (!process.env.TARGET) {
  throw new Error("TARGET package must be specified via --environment flag.")
}

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
  }
}

const packageFormats = packageOptions.formats || ["esm-bundler", "cjs"]

export default [
  ...packageFormats.map(format => {
    return createConfig(format, outputConfigs[format])
  }),
  createRollupDtsConfig({ file: resolve(`dist/${name}.d.ts`), format: "es" })
]

function createConfig(format, output) {
  if (!output) {
    console.log(require("picocolors").yellow(`invalid format: "${format}"`))
    process.exit(1)
  }

  const isWebView = name === "webview"
  const isNodeBuild = format === "cjs"
  const isGlobalBuild = /global/.test(format)

  output.exports = "named"
  output.sourcemap = !!process.env.SOURCE_MAP
  output.externalLiveBindings = false

  const plugins = [
    terser({
      module: /^esm/.test(format),
      compress: {
        ecma: 2016,
        pure_getters: true
      }
    })
  ]

  if (isGlobalBuild) {
    output.name = packageOptions.name

    plugins.push(...[commonjs(), nodeResolve()])
  }

  const shouldEmitDeclarations = pkg.types && process.env.TYPES != null && !hasTSChecked

  let tsPlugin = ts({
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
      exclude: ["**/__tests__"]
    }
  })

  hasTSChecked = true

  const external = []

  if (isWebView) {
    plugins.push(
      require("@rollup/plugin-babel").babel({
        presets: [["@babel/preset-env", { targets: { ios: 11 } }]],
        extensions: [...DEFAULT_EXTENSIONS, ".ts", ".tsx"],
        plugins: [
          [
            "@vue/babel-plugin-jsx",
            {
              isCustomElement: tag => tag.startsWith("nz-")
            }
          ]
        ]
      })
    )
    plugins.push(
      require("rollup-plugin-less")({
        output: resolve("dist/nzoth-built-in.css")
      })
    )
    plugins.push(
      // @ts-ignore
      require("rollup-plugin-copy")({
        targets: [
          {
            src: resolve("src/index.html"),
            dest: resolve("dist/")
          }
        ],
        hook: "writeBundle"
      })
    )

    // plugins.push(postcss({ plugins: [autoprefixer()] }))
  } else if (name === "nzoth" && isGlobalBuild) {
    external.push("vue")
    output.globals = { vue: "Vue" }
  } else {
    external.push(...Object.keys(pkg.dependencies || {}))

    if (name === "vite-plugin") {
      external.push(...["ws", "zlib", "path", "fs", "os", "crypto"])
    }
  }

  return {
    input: resolve("src/index.ts"),
    external,
    plugins: [
      replace({ "process.env.NODE_ENV": JSON.stringify("production"), preventAssignment: true }),
      tsPlugin,
      ...plugins
    ],
    output,
    onwarn: (msg, warn) => {
      if (!/Circular/.test(msg)) {
        warn(msg)
      }
    },
    treeshake: {}
  }
}

function createRollupDtsConfig(output) {
  output.exports = "named"

  return {
    input: resolve(`dist/packages/${name}/src/index.d.ts`),
    plugins: [dts()],
    output,
    onwarn: (msg, warn) => {
      if (!/Circular/.test(msg)) {
        warn(msg)
      }
    }
  }
}
