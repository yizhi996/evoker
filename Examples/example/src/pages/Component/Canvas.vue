<template>
  <div>Canvas 2D</div>
  <canvas type="2d" id="canvas"></canvas>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from "vue"

let ctx: CanvasRenderingContext2D
let timer: ReturnType<typeof setInterval>

onMounted(() => {
  const query = nz.createSelectorQuery()
  query
    .select("#canvas")
    .fields({ node: true, size: true })
    .exec(res => {
      const canvas = res[0].node
      ctx = canvas.getContext("2d")

      const dpr = nz.getSystemInfoSync().pixelRatio
      canvas.width = res[0].width * dpr
      canvas.height = res[0].height * dpr
      ctx.scale(dpr, dpr)

      ctx.fillRect(0, 0, 100, 100)

      timer = setInterval(render, 1000 / 60)
    })
})

onUnmounted(() => {
  clearInterval(timer)
})

const render = () => {
  if (ctx) {
  }
}
</script>
