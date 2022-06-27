// @ts-check
const { resolve } = require("path")

export function getViteConfig(target, rollupOptions, plugins = []) {
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
        plugins: [...plugins],
        rollupOptions: rollupOptions || {
          external: [...Object.keys(pkg.dependencies || {})],
          output: {
            globals: {
              vue: "Vue"
            }
          }
        }
      }
    }
  })
}
