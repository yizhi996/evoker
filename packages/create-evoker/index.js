// @ts-check

const { prompt } = require("inquirer")
const path = require("path")
const fs = require("fs")
const whichPMRuns = require("which-pm-runs")

const args = require("minimist")(process.argv.slice(2))

const TEMPLATES = ["empty-ts"]

const PLATFORMS = ["iOS"]

async function main() {
  let targetDir = args._[0] || ""
  targetDir = targetDir.trim()

  let template = args.template

  let platform = args.platform

  const dest = path.resolve(process.cwd(), targetDir)

  let projectName = path.basename(dest).trim()

  const prompts = []

  if (fs.existsSync(dest)) {
    prompts.push({
      name: "overwrite",
      message: `${path.basename(dest)} directory is not empty, overwrite files and continue?`,
      type: "confirm"
    })
    prompts.push({
      name: "overwriteConfirm",
      when: ({ overwrite }) => {
        if (overwrite) {
          return false
        }
        throw new Error("cancelled")
      }
    })
  }

  prompts.push({
    name: "projectName",
    message: "project name",
    type: "input",
    default: projectName || "evoker-project"
  })

  prompts.push({
    name: "template",
    message: "select template",
    type: "list",
    choices: TEMPLATES,
    when: () => {
      return !TEMPLATES.includes(template)
    }
  })

  prompts.push({
    name: "platform",
    message: "select platform",
    type: "list",
    choices: [...PLATFORMS, "null"],
    when: () => {
      return !PLATFORMS.includes(platform)
    }
  })

  if (prompts.length) {
    const result = await prompt(prompts)
    if (result.projectName) {
      projectName = result.projectName
    }
    if (result.template) {
      template = result.template
    }
    if (result.platform) {
      platform = result.platform.trim()
    }
  }

  if (!projectName) {
    throw new Error("project name cannot be empty")
  }

  console.log(`copying template to ${dest} ...`)

  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true })
  }

  const templateDir = path.resolve(`template-${template}`)
  let files = fs.readdirSync(templateDir).filter(f => f !== "package.json")
  if (!PLATFORMS.includes(platform)) {
    PLATFORMS.forEach(p => {
      files = files.filter(f => f !== p)
    })
  }

  files.forEach(file => {
    const filePath = path.resolve(templateDir, file)
    copy(filePath, path.resolve(dest, file))
  })

  copy(path.resolve("_gitignore"), path.resolve(dest, ".gitignore"))

  const pkgString = fs.readFileSync(path.resolve(templateDir, "package.json"), {
    encoding: "utf-8"
  })
  const pkg = JSON.parse(pkgString)
  pkg.name = projectName
  fs.writeFileSync(path.resolve(dest, "package.json"), JSON.stringify(pkg, null, 2))

  console.log("\ncompleted")
  console.log(`\n  cd ${path.basename(dest)}`)
  const mgr = whichPMRuns() || { name: "npm" }
  console.log(`  ${mgr.name} install`)
  console.log(`  ${mgr.name} run dev`)

  if (platform === "iOS") {
    console.log(`\n  cd ${path.basename(dest)}/iOS`)
    console.log(`  pod install`)
  }
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true })
  fs.readdirSync(src).forEach(file => {
    copy(path.resolve(src, file), path.resolve(dest, file))
  })
}

function copy(src, dest) {
  if (fs.statSync(src).isDirectory()) {
    copyDir(src, dest)
  } else {
    fs.copyFileSync(src, dest)
  }
}

main()
