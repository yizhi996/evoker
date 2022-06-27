// @ts-check
const { resolve } = require("path")
const fs = require("fs")
const archiver = require("archiver")

const root = resolve(__dirname, "../packages/")

const nzothDir = resolve(root, "nzoth")
const version = require(resolve(nzothDir, "package.json")).version

const include = {
  nzoth: ["nzoth.global.prod.js"],
  webview: ["webview.global.prod.js", "nzoth-built-in.css", "index.html"],
  vue: ["vue.runtime.global.prod.js"]
}

const dir = resolve(__dirname, "../temp")

const fileName = `nzoth-sdk-${version}.nzpkg`
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir)
}

const output = resolve(dir, fileName)

const stream = fs.createWriteStream(output)

const archive = archiver.create("zip", { zlib: { level: 9 } })

let totalSize = 0

stream.on("finish", () => {
  const stat = fs.statSync(output)
  console.log(`${fileName} - ${toKiB(totalSize)} - zip ${toKiB(stat.size)}`)

  fs.copyFileSync(output, resolve(__dirname, `../iOS/NZoth/Sources/Resources/SDK/nzoth-sdk.nzpkg`))
})

const toKiB = n => {
  return (n / 1024).toFixed(2) + " KiB"
}

archive
  // @ts-ignore
  .on("error", err => {
    console.log("zip err: ", err)
  })
  .pipe(stream)

Object.keys(include).forEach(pkg => {
  const dir = resolve(root, `${pkg}/dist`)
  include[pkg].forEach(file => {
    const fp = resolve(dir, file)

    archive.file(fp, { name: file })

    const stat = fs.statSync(fp)
    totalSize += stat.size
  })
})

archive.finalize()
