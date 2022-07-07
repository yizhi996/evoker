// @ts-check
const { resolve } = require("path")
const fs = require("fs")

const getPkgDir = target => resolve(__dirname, `../packages/${target}`)

exports.getPkgDir = getPkgDir

const getPkg = target => require(resolve(`${getPkgDir(target)}/package.json`))

exports.getPkg = getPkg

exports.createViteConfig = function (options) {
  const { target, resolve: _resolve, rollupOptions, plugins, test } = options

  const pkg = getPkg(target)

  const { defineConfig } = require("vite")

  return defineConfig(() => {
    return {
      resolve: _resolve,
      build: {
        lib: {
          entry: resolve(getPkgDir(target), "src/index.ts"),
          name: pkg.buildOptions.name,
          fileName: foramt => `${target}.${foramt === "iife" ? "global" : foramt}.js`,
          formats: pkg.buildOptions.formats.map(f => {
            return f === "global" ? "iife" : f
          })
        },
        rollupOptions: rollupOptions || {
          external: [...Object.keys(pkg.dependencies || {})],
          output: {
            globals: {
              vue: "Vue"
            }
          }
        }
      },
      plugins,
      test
    }
  })
}

exports.allPakcages = function () {
  const root = resolve(__dirname, "../packages")
  return fs.readdirSync(root).filter(pkg => {
    return (
      fs.statSync(resolve(root, pkg)).isDirectory() && require(resolve(root, `${pkg}/package.json`))
    )
  })
}

exports.evokerPkg = function evokerPkg() {
  return getPkg("evoker")
}
