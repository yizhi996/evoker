#!/usr/bin/env node

// @ts-check
import path from "node:path"
import fs from "node:fs"
import { createPromptModule } from "inquirer"
import { fileURLToPath } from "node:url"
import whichPMRuns from "which-pm-runs"
import minimist from "minimist"
import { execa } from "execa"

const args = minimist(process.argv.slice(2))

const TEMPLATES = ["blank"]

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
    const prompt = createPromptModule()
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

  const root = path.resolve(fileURLToPath(import.meta.url), "..")

  const templateDir = path.resolve(root, `template-${template}`)
  let files = fs.readdirSync(templateDir)
  PLATFORMS.forEach(p => {
    files = files.filter(f => f !== p)
  })

  files.forEach(file => {
    copy(path.resolve(templateDir, file), path.resolve(dest, file))
  })

  modifyJSON(path.resolve(dest, "package.json"), pkg => {
    pkg.name = projectName
  })

  modifyJSON(path.resolve(dest, "src/app.json"), app => {
    app.appId = `com.evokerdev.${sanitizedName(projectName)}`
  })

  if (platform === "iOS") {
    copyiOS(path.resolve(root, "template-iOS"), dest)
    const builtIniOSDir = path.resolve(templateDir, "iOS")
    if (fs.existsSync(builtIniOSDir)) {
      copyiOS(builtIniOSDir, path.resolve(dest))
    }
  }

  copy(path.resolve(root, "_gitignore"), path.resolve(dest, ".gitignore"))
  copy(path.resolve(root, "_README.md"), path.resolve(dest, "README.md"))

  const mgr = whichPMRuns() || { name: "npm" }

  await execa(mgr.name, ["install"], { cwd: dest, stdio: "inherit" })

  console.log("\ncompleted")
  console.log(`\n  cd ${path.basename(dest)}`)
  console.log(`  ${mgr.name} run dev`)

  if (platform === "iOS") {
    console.log(`\n  cd ${path.basename(dest)}/iOS`)
    console.log(`  pod install`)
  }
}

function sanitizedName(string) {
  return string.replace(/-(\w)/g, (_, w) => {
    return w
  })
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

function modifyJSON(src, modify) {
  const string = fs.readFileSync(src, { encoding: "utf-8" })
  const data = JSON.parse(string)
  modify(data)
  fs.writeFileSync(src, JSON.stringify(data, null, 2), { encoding: "utf-8" })
}

function copyiOS(root, dest) {
  const files = fs.readdirSync(root)

  const dir = path.join(dest, "iOS")
  !fs.existsSync(dir) && fs.mkdirSync(dir, { recursive: true })

  files.forEach(file => {
    copy(path.resolve(root, file), path.resolve(dir, file))
  })
}

main()
