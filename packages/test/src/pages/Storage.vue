<template>
  <task-board :task="task"></task-board>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { describe, run } from "../test"

const task = describe("storage", async ctx => {
  await ek.clearStorage({})

  ctx.test("set", async () => {
    const res = await ek.setStorage({ key: "test_string", data: "string" })
    ctx.expect(res.errMsg).toContain("ok")
  })

  ctx.test("get", async () => {
    const res = await ek.getStorage({ key: "test_string" })
    ctx.expect(res.data).toBe("string")
  })

  ctx.test("remove", async () => {
    const res = await ek.removeStorage({ key: "test_string" })
    ctx.expect(res.errMsg).toContain("ok")
  })

  ctx.test("info", async () => {
    await ek.setStorage({ key: "test_string", data: "string" })
    const res = await ek.getStorageInfo({})
    ctx.expect(res.keys).toContain("test_string")
  })

  ctx.test("clean", async () => {
    await ek.clearStorage({})
    const res = await ek.getStorageInfo({})
    ctx.expect(res.keys).toEqual([])
  })
})

const { onReady } = usePage()

onReady(() => {
  run(task)
})
</script>
