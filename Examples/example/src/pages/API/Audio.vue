<template>
  <n-topic>{{ formatSecond(currentTime) }} / {{ formatSecond(duration) }}</n-topic>
  <button type="primary" @click="play">Play</button>
  <button @click="pause">Pause</button>
  <button @click="stop">Stop</button>
  <slider class="mt-10" :value="slide" @changing="onSliding" @change="seek"></slider>
  <div class="flex items-center justify-center">
    <switch @change="changePlaybackRate"></switch>
    <span>倍速 2x</span>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { formatSecond } from "../../utils"

const currentTime = ref(0)

const duration = ref(0)

const slide = ref(0)

let isSliding = false

const ctx = ev.createInnerAudioContext()

ctx.onTimeUpdate(() => {
  currentTime.value = ctx.currentTime
  if (!isSliding) {
    slide.value = (ctx.currentTime / ctx.duration) * 100
  }
})

ctx.onCanplay(() => {
  duration.value = ctx.duration
})

ctx.onSeeked(() => {
  isSliding = false
})

ctx.src = "https://file.lilithvue.com/lilith-test-assets/3EM27_Beethoven9_Orch%2BCho.mp3"
ctx.volume = 0.3
ctx.loop = true

const play = () => {
  ctx.play()
}

const pause = () => {
  ctx.pause()
}

const stop = () => {
  ctx.stop()
}

const onSliding = () => {
  isSliding = true
}

const seek = e => {
  const value = e.detail.value
  slide.value = value
  const seekTo = ctx.duration * (value / 100)
  ctx.seek(seekTo)
}

const changePlaybackRate = e => {
  const value = e.detail.value
  ctx.playbackRate = value ? 2.0 : 1.0
}
</script>
