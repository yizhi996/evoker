// @ts-check

const semver = require("semver")
const { prompt } = require("inquirer")
const { evokerPkg, allPakcages } = require("./utils")
const colors = require("picocolors")
const { resolve } = require("path")
const fs = require("fs")
const execa = require("execa")

const mainPkg = evokerPkg()

const currentVersion = mainPkg.version

;(async function () {
  const { release } = await prompt([
    {
      name: "release",
      message: "select release type",
      type: "list",
      choices: ["major", "minor", "patch", "custom"]
    }
  ])

  let targetVersion

  if (release === "custom") {
    const { custom } = await prompt([
      {
        name: "custom",
        message: "input custom version",
        type: "input"
      }
    ])
    targetVersion = custom
  } else {
    targetVersion = semver.inc(currentVersion, release)
  }

  if (!semver.valid(targetVersion)) {
    throw new Error(`target version invalid: ${targetVersion}`)
  }

  const { yes } = await prompt([
    {
      name: "yes",
      message: `release ${targetVersion}`,
      type: "confirm"
    }
  ])

  if (!yes) {
    return
  }

  const packages = allPakcages()
  console.log(colors.bold(colors.cyan("modify package version")))
  packages.forEach(p => updatePackageVersion(p, targetVersion))

  console.log(colors.bold(colors.cyan("start publish")))
  for (const package of packages) {
    await publish(package)
  }
  console.log(colors.bold(colors.cyan(`completed release to ${targetVersion}!`)))
})()

function updatePackageVersion(package, targetVersion) {
  const pkgDir = resolve(`packages/${package}/package.json`)
  const pkg = JSON.parse(fs.readFileSync(pkgDir, { encoding: "utf-8" }))
  pkg.version = targetVersion
  updatePackageDependencitsVersion(pkg.dependencies, targetVersion)
  updatePackageDependencitsVersion(pkg.devDependencies, targetVersion)
  fs.writeFileSync(pkgDir, JSON.stringify(pkg, null, 2) + "\n", { encoding: "utf-8" })
}

function updatePackageDependencitsVersion(dependencies, targetVersion) {
  if (!dependencies) {
    return
  }

  for (const pkg in dependencies) {
    if (pkg.startsWith("@evoker")) {
      dependencies[pkg] = targetVersion
    }
  }
}

async function publish(package) {
  const pkgDir = resolve(`packages/${package}`)
  try {
    await execa("npm", ["publish", "--access", "public"], { stdio: "inherit", cwd: pkgDir })
    console.log(colors.bold(colors.cyan("publish success")))
  } catch (e) {
    console.log(colors.bold(colors.red(`publish fail: ${e}`)))
    throw e
  }
}
