<template>
  <div class="mx-10 my-3 flex flex-col space-y-4">
    <progress :percent="10" show-info></progress>
    <progress :percent="30"></progress>
    <progress
      :percent="50"
      stroke-width="8px"
      active-color="orange"
      background-color="green"
    ></progress>
    <progress :percent="percent" show-info active active-mode="forwards"></progress>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { usePage } from "evoker"
const percent = ref(0)

const { onLoad, onUnload } = usePage()

let timer: ReturnType<typeof setInterval>

onLoad(() => {
  timer = setInterval(() => {
    percent.value += 10
    if (percent.value >= 70) {
      clearInterval(timer)
    }
  }, 1000)
})

onUnload(() => {
  clearInterval(timer)
})
</script>
