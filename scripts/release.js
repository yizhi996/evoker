// @ts-check

const semver = require("semver")
const { prompt } = require("inquirer")
const { evokerPkg, allPakcages, getPkgDir, readdir } = require("./utils")
const colors = require("picocolors")
const fs = require("fs")
const execa = require("execa")
const { resolve } = require("path")

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

  const packages = allPakcages().filter(p => p !== "create-evoker")
  console.log(colors.bold(colors.cyan("modify package version")))
  packages.forEach(p => updatePackageVersion(p, targetVersion))

  console.log(colors.bold(colors.cyan("start publish")))
  for (const package of packages) {
    await publish(package)
  }

  await execa("pnpm", ["i"], { stdio: "inherit" })

  updateCreateTemplateDependenciesVersion("^" + targetVersion)
  updateCreateTemplatePodfileVersion(targetVersion)
  removeCreateTemplateNodeModules()

  console.log(colors.bold(colors.cyan(`completed release to ${targetVersion}!`)))
})()

function updatePackage(pkgDir, exec) {
  const pkg = JSON.parse(fs.readFileSync(pkgDir, { encoding: "utf-8" }))
  exec(pkg)
  fs.writeFileSync(pkgDir, JSON.stringify(pkg, null, 2) + "\n", { encoding: "utf-8" })
}

function updatePackageVersion(package, targetVersion) {
  updatePackage(resolve(getPkgDir(package), "package.json"), pkg => {
    pkg.version = targetVersion
    updatePackageDependenciesVersion(pkg.dependencies, targetVersion)
    updatePackageDependenciesVersion(pkg.devDependencies, targetVersion)
  })
}

function updatePackageDependenciesVersion(dependencies, targetVersion) {
  if (!dependencies) {
    return
  }

  for (const pkg in dependencies) {
    if (pkg.startsWith("@evoker") || pkg === "evoker") {
      dependencies[pkg] = targetVersion
    }
  }
}

function updateCreateTemplateDependenciesVersion(targetVersion) {
  readdir(getPkgDir("create-evoker"))
    .filter(f => f.includes("template-") && f.includes("package.json"))
    .forEach(f => {
      updatePackage(f, pkg => {
        updatePackageDependenciesVersion(pkg.dependencies, targetVersion)
        updatePackageDependenciesVersion(pkg.devDependencies, targetVersion)
      })
    })
}

function removeCreateTemplateNodeModules() {
  readdir(getPkgDir("create-evoker"))
    .filter(f => f.includes("template-") && f.includes("node_modules"))
    .forEach(f => {
      if (fs.existsSync(f)) {
        fs.rmSync(f, { recursive: true, force: true })
      }
    })
}

function updateCreateTemplatePodfileVersion(targetVersion) {
  readdir(getPkgDir("create-evoker"))
    .filter(f => f.includes("Podfile"))
    .forEach(f => {
      const pod = fs.readFileSync(f, { encoding: "utf-8" })
      const lines = pod.split("\n")
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i]
        if (line.includes("Evoker")) {
          const search = "~> "
          const start = line.indexOf(search)
          if (start > -1) {
            const end = line.lastIndexOf("'")
            lines[i] =
              line.substring(0, start + search.length) + targetVersion + line.substring(end)
          }
        }
      }
      fs.writeFileSync(f, lines.join("\n"), { encoding: "utf-8" })
    })
}

async function publish(package) {
  const pkgDir = getPkgDir(package)
  try {
    await execa("npm", ["publish", "--access", "public"], { stdio: "inherit", cwd: pkgDir })
    console.log(colors.bold(colors.cyan("publish success")))
  } catch (e) {
    console.log(colors.bold(colors.red(`publish fail: ${e}`)))
    throw e
  }
}
