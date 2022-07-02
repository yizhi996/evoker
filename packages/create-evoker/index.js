#!/usr/bin/env node

// @ts-check
import path from "node:path"
import fs from "node:fs"
import { createPromptModule } from "inquirer"
import { fileURLToPath } from "node:url"
import whichPMRuns from "which-pm-runs"
import minimist from "minimist"

const args = minimist(process.argv.slice(2))

const TEMPLATES = ["blank", "example"]

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
    copyiOS(path.resolve(root, "template-iOS"), dest, projectName)
    const builtIniOSDir = path.resolve(templateDir, "iOS")
    if (fs.existsSync(builtIniOSDir)) {
      copyiOS(builtIniOSDir, path.resolve(dest), projectName)
    }
  }

  copy(path.resolve(root, "_gitignore"), path.resolve(dest, ".gitignore"))
  copy(path.resolve(root, "_README.md"), path.resolve(dest, "README.md"))

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

function sanitizedName(string) {
  return string.replace(/-(\w)/g, (_, w) => {
    return w
  })
}

function firstLetterUpperCase(string) {
  return string.replace(/\b\w/g, w => {
    return w.toUpperCase()
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

function copyiOS(root, dest, projectName) {
  const files = fs.readdirSync(root)

  const dir = path.join(dest, "iOS")
  !fs.existsSync(dir) && fs.mkdirSync(dir, { recursive: true })

  const name = firstLetterUpperCase(sanitizedName(projectName))

  files.forEach(file => {
    copy(path.resolve(root, file), path.resolve(dir, file.replace(/Runner/g, name)))
  })

  replaceiOSProjectConfig(dir, projectName)
}

function replaceiOSProjectConfig(dest, projectName) {
  const files = fs.readdirSync(dest)
  files.forEach(file => {
    replace(path.resolve(dest, file), projectName)
  })
}

function replace(src, projectName) {
  if (fs.statSync(src).isDirectory()) {
    fs.readdirSync(src).forEach(file => {
      replace(path.resolve(src, file), projectName)
    })
  } else {
    let data = fs.readFileSync(src, { encoding: "utf-8" })
    const name = sanitizedName(projectName)
    data = data.replace(/Runner/g, firstLetterUpperCase(name)).replace(/runner/g, name)
    fs.writeFileSync(src, data, { encoding: "utf-8" })
  }
}

main()
