// @ts-check
const { resolve } = require("path")
const fs = require("fs")

exports.getViteConfig = function (target, rollupOptions, plugins = []) {
  const pkgDir = resolve(`packages/${target}`)
  const pkg = require(resolve(`${pkgDir}/package.json`))

  const { defineConfig } = require("vite")

  return defineConfig(() => {
    return {
      build: {
        lib: {
          entry: resolve(pkgDir, "src/index.ts"),
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
      plugins
    }
  })
}

exports.allPakcages = function () {
  return fs.readdirSync("packages").filter(pkg => {
    return (
      fs.statSync(`packages/${pkg}`).isDirectory() && require(`../packages/${pkg}/package.json`)
    )
  })
}

exports.evokerPkg = function evokerPkg() {
  const pkgDir = resolve("packages/evoker")
  const pkg = require(resolve(`${pkgDir}/package.json`))
  return pkg
}
