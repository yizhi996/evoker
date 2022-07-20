// @ts-check
const { resolve } = require("path")
const fs = require("fs")

const getPkgDir = target => resolve(__dirname, `../packages/${target}`)

exports.getPkgDir = getPkgDir

const getPkg = target => require(resolve(`${getPkgDir(target)}/package.json`))

exports.getPkg = getPkg

exports.createViteConfig = function (options) {
  const { target, vite = {} } = options

  const pkg = getPkg(target)

  const { mergeConfig } = require("vite")
  const config = mergeConfig(
    {
      define: {
        "process.env.NODE_ENV": JSON.stringify("development")
      },
      build: {
        lib: {
          entry: resolve(getPkgDir(target), "src/index.ts"),
          name: pkg.buildOptions.name,
          fileName: foramt => `${target}.${foramt === "iife" ? "global" : foramt}.js`,
          formats: pkg.buildOptions.formats.map(f => {
            return f === "global" ? "iife" : f
          })
        },
        rollupOptions: {
          external: vite.build?.rollupOptions?.external || [...Object.keys(pkg.dependencies || {})],
          output: {
            globals: {
              vue: "Vue"
            }
          }
        }
      }
    },
    vite
  )
  return config
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
