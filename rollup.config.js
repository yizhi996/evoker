// @ts-check
import path from "path"
import ts from "rollup-plugin-typescript2"
import { DEFAULT_EXTENSIONS } from "@babel/core"
import nodeResolve from "@rollup/plugin-node-resolve"
import replace from "@rollup/plugin-replace"
import dts from "rollup-plugin-dts"
import fs from "fs"

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
  es: {
    file: resolve(`dist/${name}.js`),
    format: "es"
  },
  cjs: {
    file: resolve(`dist/${name}.cjs.js`),
    format: "cjs"
  },
  iife: {
    file: resolve(`dist/${name}.global.js`),
    format: "iife"
  }
}

const packageFormats = packageOptions.formats || ["es"]

export default [
  ...packageFormats.map(format => {
    return createConfig(format, outputConfigs[format])
  }),
  ...packageFormats
    .map(format => {
      if (/iife/.test(format)) {
        return createTerserConfig(format)
      }
    })
    .filter(Boolean),
  createRollupDtsConfig({ file: resolve(`dist/${name}.d.ts`), format: "es" })
]

function createConfig(format, output, plugins = []) {
  if (!output) {
    console.log(require("picocolors").yellow(`invalid format: "${format}"`))
    process.exit(1)
  }

  const isWebView = name === "webview"
  const isNodeBuild = format === "cjs"
  const isGlobalBuild = /iife/.test(format)

  output.exports = "named"
  output.sourcemap = !!process.env.SOURCE_MAP
  output.externalLiveBindings = false

  if (isGlobalBuild) {
    output.name = packageOptions.name
    plugins.push(nodeResolve())
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
    output.assetFileNames = () => "evoker-built-in.css"

    // @ts-ignore
    plugins.push(require("rollup-plugin-styles")({ mode: "extract" }))

    plugins.push(
      require("@rollup/plugin-babel").babel({
        presets: [["@babel/preset-env", { targets: { ios: 11 } }]],
        extensions: [...DEFAULT_EXTENSIONS, ".ts", ".tsx"],
        plugins: [
          [
            "@vue/babel-plugin-jsx",
            {
              isCustomElement: tag => tag.startsWith("ek-")
            }
          ]
        ]
      })
    )
  } else if (name === "evoker" && isGlobalBuild) {
    external.push("vue")
    output.globals = { vue: "Vue" }
  } else {
    external.push(...Object.keys(pkg.dependencies || {}))

    if (name === "cli") {
      const builtinModules = require("builtin-modules")
      external.push(...builtinModules)
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

function createTerserConfig(format) {
  const { terser } = require("rollup-plugin-terser")

  const { file, format: fmt } = outputConfigs[format]

  const isWebView = name === "webview"

  return createConfig(
    format,
    {
      file: file.replace(/.js$/, ".prod.js"),
      format: fmt
    },
    [
      terser({
        module: false,
        compress: {
          ecma: 2016,
          pure_getters: true
        }
      }),
      isWebView
        ? {
            name: "evoker:minify",
            writeBundle() {
              const { transform } = require("esbuild")

              const files = [
                { src: "dist/evoker-built-in.css", loader: "css" },
                { src: "src/index.html", dest: "dist/index.html", loader: "ignore" }
              ]

              files.forEach(async ({ src, dest, loader }) => {
                const data = fs.readFileSync(resolve(src), { encoding: "utf-8" })
                let res = data
                if (loader !== "ignore") {
                  // @ts-ignore
                  const { code } = await transform(data, { loader: loader, minify: true })
                  res = code
                }
                fs.writeFileSync(resolve(dest || src), res, { encoding: "utf-8" })
              })
            }
          }
        : null
    ]
  )
}

function createRollupDtsConfig(output) {
  output.exports = "named"

  const plugins = [dts()]
  if (name === "evoker") {
    plugins.push(
      // @ts-ignore
      require("rollup-plugin-copy")({
        targets: [
          {
            src: resolve("global.d.ts"),
            dest: resolve("dist/")
          }
        ],
        hook: "writeBundle"
      })
    )
  }

  return {
    input: resolve(`dist/packages/${name}/src/index.d.ts`),
    plugins,
    output,
    external: [/\.less$/u],
    onwarn: (msg, warn) => {
      if (!/Circular/.test(msg)) {
        warn(msg)
      }
    }
  }
}
