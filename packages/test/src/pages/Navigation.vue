<template>
  <task-board :task="task"></task-board>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { describe, run } from "../test"

const task = describe("navigation", ctx => {
  ctx.test("showNavigationBarLoading", () => {
    ek.showNavigationBarLoading()
    ctx.expect(__TestUtils.containImage("navigation-loading")).toBe(true)
  })

  ctx.test("hideNavigationBarLoading", () => {
    ek.hideNavigationBarLoading()
    ctx.expect(__TestUtils.containImage("navigation-loading")).toBe(false)
  })

  const title = "Evoker!!!"
  ctx.test("setNavigationBarTitle", () => {
    ek.setNavigationBarTitle({ title })
    ctx.expect(__TestUtils.containText(title)).toBe(true)
  })

  const backgroundColor = "#ff00ff"
  ctx.test("setNavigationBarColor back", () => {
    ek.setNavigationBarColor({ frontColor: "#ffffff", backgroundColor })
    const view = __TestUtils.findUIViewWithClass("Evoker.NavigationBar")!
    ctx.expect(view.backgroundColor).toBe(backgroundColor)
  })

  ctx.test("setNavigationBarColor front", () => {
    const frontColor = "#000000"
    ek.setNavigationBarColor({
      frontColor,
      backgroundColor
    })
    const view = __TestUtils.findUILabelWithText(title)!
    ctx.expect(view.textColor).toBe(frontColor)
  })
})

const { onReady } = usePage()

onReady(() => {
  run(task)
})
</script>
