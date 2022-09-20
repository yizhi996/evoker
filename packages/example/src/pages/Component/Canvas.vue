<template>
  <canvas type="2d" id="canvas" style="width: 300px; height: 300px"></canvas>
</template>

<script setup lang="ts">
import { usePage } from "evoker"

const { onReady } = usePage()

let canvas: HTMLCanvasElement
let ctx: CanvasRenderingContext2D

let carImage: CanvasImageSource

onReady(() => {
  const query = ek.createSelectorQuery()
  query
    .select("#canvas")
    .fields({ node: true, size: true })
    .exec(res => {
      const width = res[0].width
      const height = res[0].height
      canvas = res[0].node!
      ctx = canvas.getContext("2d")!

      const dpr = ek.getSystemInfoSync().pixelRatio
      canvas.width = width * dpr
      canvas.height = height * dpr
      ctx.scale(dpr, dpr)

      const renderLoop = () => {
        render()
        canvas.requestAnimationFrame(renderLoop)
      }
      canvas.requestAnimationFrame(renderLoop)

      const img = canvas.createImage()
      img.onload = () => {
        carImage = img
      }
      img.src = "assets/car.png"
    })
})

const render = () => {
  ctx.clearRect(0, 0, 300, 300)
  drawBall()
  drawCar()
}

let position = {
  x: 150,
  y: 150,
  vx: 2,
  vy: 2
}

let x = -100

const drawBall = () => {
  const p = position
  p.x += p.vx
  p.y += p.vy
  if (p.x >= 300) {
    p.vx = -2
  }
  if (p.x <= 7) {
    p.vx = 2
  }
  if (p.y >= 300) {
    p.vy = -2
  }
  if (p.y <= 7) {
    p.vy = 2
  }

  function ball(x: number, y: number) {
    ctx.beginPath()
    ctx.arc(x, y, 5, 0, Math.PI * 2)
    ctx.fillStyle = "#1aad19"
    ctx.strokeStyle = "rgba(1,1,1,0)"
    ctx.fill()
    ctx.stroke()
  }

  ball(p.x, 150)
  ball(150, p.y)
  ball(300 - p.x, 150)
  ball(150, 300 - p.y)
  ball(p.x, p.y)
  ball(300 - p.x, 300 - p.y)
  ball(p.x, 300 - p.y)
  ball(300 - p.x, p.y)
}

const drawCar = () => {
  if (!carImage) {
    return
  }

  if (x > 350) {
    x = -100
  }

  ctx.drawImage(carImage, x++, 150 - 25, 100, 50)
  ctx.restore()
}
</script>
