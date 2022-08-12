// @ts-check
import { resolve, dirname } from "path"
import fs from "fs"
import { fileURLToPath } from "url"
import { mergeConfig } from "vite"

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export const packageDirectory = target => resolve(__dirname, `../packages/${target}`)

export const packageObject = target =>
  JSON.parse(
    fs.readFileSync(resolve(`${packageDirectory(target)}/package.json`), { encoding: "utf-8" })
  )

export function createViteConfig(options) {
  const { target, vite = {} } = options

  const pkg = packageObject(target)

  const config = mergeConfig(
    {
      define: {
        "process.env.NODE_ENV": JSON.stringify("development")
      },
      build: {
        lib: {
          entry: resolve(packageDirectory(target), "src/index.ts"),
          name: pkg.buildOptions.name,
          formats: pkg.buildOptions.formats || ["es"],
          fileName: format =>
            `${target}${format === "iife" ? ".global" : format === "es" ? "" : `.${format}`}.js`
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

export function allPakcages() {
  const root = resolve(__dirname, "../packages")
  return fs.readdirSync(root).filter(pkg => {
    return fs.statSync(resolve(root, pkg)).isDirectory()
  })
}

export function readdir(path) {
  const files = []
  fs.readdirSync(path).forEach(f => {
    const fp = resolve(path, f)
    if (fs.statSync(fp).isDirectory()) {
      files.push(...readdir(fp))
    } else {
      files.push(fp)
    }
  })
  return files
}
