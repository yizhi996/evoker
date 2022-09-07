<template>
  <task-board :task="task"></task-board>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { describe, run } from "../test"

const task = describe("request", ctx => {
  ctx.test("get", () => {
    ek.request({
      url: "https://lilithvue.com/api/test",
      data: { id: "100" },
      success: res => {
        const data = res.data as any
        ctx.expect(data.query.id).toBe("100")
      }
    })
  })

  ctx.test("post", () => {
    ek.request({
      url: "https://lilithvue.com/api/test",
      method: "POST",
      data: { id: "100" },
      success: res => {
        const data = res.data as any
        ctx.expect(data.body.id).toBe("100")
      }
    })
  })

  ctx.test("download", () => {
    ek.downloadFile({
      url: "https://file.lilithvue.com/lilith-test-assets/wallhaven-43y68y.jpg?imageMogr2/thumbnail/512x",
      filePath: ek.env.USER_DATA_PATH + "/test_img.jpg",
      success: res => {
        ctx.expect(res.filePath).toContain("test_img.jpg")
      }
    })
  })
})

const { onReady } = usePage()

onReady(() => {
  run(task)
})
</script>
