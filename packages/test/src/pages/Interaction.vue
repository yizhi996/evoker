<template>
  <task-board :task="task"></task-board>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { describe, run } from "../test"

const ANIMATION_DURATION = 500

const task = describe("interaction", ctx => {
  ctx.test("showToast", async () => {
    const title = "Test"
    await ek.showToast({ title })
    ctx.expect(__TestUtils.containText(title) && __TestUtils.containImage("hud-success-icon")).toBe(true)
    ek.hideToast()
  })

  ctx.test(
    "showToast none icon",
    async () => {
      await ek.showToast({ title: "None", icon: "none" })
      ctx.expect(__TestUtils.containImage("hud-success-icon")).toBe(false)
      ek.hideToast()
    },
    ANIMATION_DURATION
  )

  ctx.test(
    "hideToast",
    async () => {
      const title = "Hide Toast"
      await ek.showToast({ title })
      await ek.hideToast()
      setTimeout(() => {
        ctx.expect(__TestUtils.containText(title)).toBe(false)
      }, ANIMATION_DURATION)
    },
    ANIMATION_DURATION
  )

  ctx.test("showModal", () => {
    const title = "Title"
    const content = "Content"
    ek.showModal({ title, content })
    ctx.expect(__TestUtils.containText(title) && __TestUtils.containText(content)).toBe(true)
    __TestUtils.findUIButtonWithTitle("确定")?.click()
  })

  ctx.test(
    "showModal hide cancel",
    () => {
      const title = "Title"
      ek.showModal({ title, showCancel: false })
      ctx.expect(__TestUtils.containText("取消")).toBe(false)
      __TestUtils.findUIButtonWithTitle("确定")?.click()
    },
    ANIMATION_DURATION
  )

  ctx.test(
    "showModal confirmColor",
    () => {
      const title = "1Title"
      const confirmColor = "#ff00ff".toLowerCase()
      ek.showModal({ title, showCancel: false, confirmColor })
      const button = __TestUtils.findUIButtonWithTitle("确定")!
      console.log(button)
      ctx.expect(button.titleColor).toBe(confirmColor)
      button.click()
    },
    ANIMATION_DURATION
  )

  ctx.test(
    "showModal editable",
    () => {
      const title = "Title"
      const inputValue = "OKOK"
      ek.showModal({
        title,
        editable: true,
        placeholderText: "PLACEHOLDER",
        success: res => {
          ctx.expect(res.content).toBe(inputValue)
        }
      })
      const input = __TestUtils.findFirstResponderInput()!
      input.text = inputValue
      const button = __TestUtils.findUIButtonWithTitle("确定")!
      button.click()
    },
    ANIMATION_DURATION
  )

  ctx.test("showLoading", async () => {
    const title = "Loading"
    await ek.showLoading({ title })
    ctx.expect(__TestUtils.containText(title) && __TestUtils.containImage("hud-loading-icon")).toBe(true)
  })

  ctx.test("hideLoading", () => {
    ek.hideLoading()
    setTimeout(() => {
      ctx.expect(__TestUtils.containImage("hud-loading-icon")).toBe(false)
    }, ANIMATION_DURATION)
  })

  ctx.test("showActionSheet", () => {
    ek.showActionSheet({
      itemList: ["iOS", "macOS"],
      success: res => {
        ctx.expect(res.tapIndex).toBe(1)
      }
    })
    setTimeout(() => {
      __TestUtils.clickTableViewCellWithTitle("macOS")
    }, ANIMATION_DURATION)
  })
})

const { onReady } = usePage()

onReady(() => {
  run(task)
})
</script>
