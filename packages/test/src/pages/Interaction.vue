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
    ctx.expect(__TestUtils.findText(title) && __TestUtils.findImage("hud-success-icon")).toBe(true)
    ek.hideToast()
  })

  ctx.test(
    "showToast none icon",
    async () => {
      await ek.showToast({ title: "None", icon: "none" })
      ctx.expect(__TestUtils.findImage("hud-success-icon")).toBe(false)
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
        ctx.expect(__TestUtils.findText(title)).toBe(false)
      }, ANIMATION_DURATION)
    },
    ANIMATION_DURATION
  )

  ctx.test("showModal", () => {
    const title = "Title"
    const content = "Content"
    ek.showModal({ title, content })
    ctx.expect(__TestUtils.findText(title) && __TestUtils.findText(content)).toBe(true)
    __TestUtils.clickButtonWithTitle("确定")
  })

  ctx.test(
    "showModal hide cancel",
    () => {
      const title = "Title"
      ek.showModal({ title, showCancel: false })
      ctx.expect(__TestUtils.findText("取消")).toBe(false)
      __TestUtils.clickButtonWithTitle("确定")
    },
    ANIMATION_DURATION
  )

  ctx.test(
    "showModal confirmColor",
    () => {
      const title = "Title"
      const confirmColor = "#ff00ff".toLowerCase()
      ek.showModal({ title, showCancel: false, confirmColor })
      const button = __TestUtils.findUIButtonWithTitle("确定")!
      ctx.expect(button.titleColor).toBe(confirmColor)
      __TestUtils.clickButtonWithId(button.id)
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
      __TestUtils.setInput(input, inputValue)
      const button = __TestUtils.findUIButtonWithTitle("确定")!
      __TestUtils.clickButtonWithId(button.id)
    },
    ANIMATION_DURATION
  )

  ctx.test("showLoading", async () => {
    const title = "Loading"
    await ek.showLoading({ title })
    ctx.expect(__TestUtils.findText(title) && __TestUtils.findImage("hud-loading-icon")).toBe(true)
  })

  ctx.test("hideLoading", () => {
    ek.hideLoading()
    setTimeout(() => {
      ctx.expect(__TestUtils.findImage("hud-loading-icon")).toBe(false)
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
