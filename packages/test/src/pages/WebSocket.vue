<template>
  <task-board :task="task"></task-board>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { describe, run } from "../test"

const task = describe("web socket", async ctx => {
  ctx.test("send / recv", async () => {
    const ws = ek.connectSocket({ url: "wss://lilithvue.com/echo" })!
    ws.onOpen(() => {
      ws.send({ data: "hello" })
    })

    ws.onMessage(res => {
      ws.close()
      ctx.expect(res.data).toBe("hello")
    })
  })
})

const { onReady } = usePage()

onReady(() => {
  run(task)
})
</script>
