// @ts-check
import path from "path"
import dts from "rollup-plugin-dts"

if (!process.env.TARGET) {
  throw new Error("TARGET package must be specified via --environment flag.")
}

const packagesDir = path.resolve(__dirname, "packages")
const packageDir = path.resolve(packagesDir, process.env.TARGET)
const resolve = p => path.resolve(packageDir, p)
const pkg = require(resolve(`package.json`))
const packageOptions = pkg.buildOptions || {}
const name = packageOptions.filename || path.basename(packageDir)

export default createConfig({ file: resolve(`dist/${name}.d.ts`), format: "es" })

function createConfig(output) {
  output.exports = "named"

  let entryFile = `dist/packages/${name}/src/index.d.ts`

  return {
    input: resolve(entryFile),
    plugins: [dts()],
    output,
    onwarn: (msg, warn) => {
      if (!/Circular/.test(msg)) {
        warn(msg)
      }
    }
  }
}
