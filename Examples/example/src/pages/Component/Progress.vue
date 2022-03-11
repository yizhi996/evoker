<template>
  <div class="mx-10 my-3 flex flex-col">
    <progress class="mt-5" :percentage="10" :show-privot="false"></progress>
    <progress class="mt-5" :percentage="30"></progress>
    <progress class="mt-5" :percentage="50" stroke-width="8px" color="red" track-color="green"></progress>
    <progress class="mt-5" :percentage="percent"></progress>
    <progress class="mt-5" :percentage="9999"></progress>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { usePage } from "nzoth"
const percent = ref(0)

const { onLoad } = usePage()

let timer: ReturnType<typeof setTimeout>

onLoad(() => {
  timer = setInterval(() => {
    percent.value += 10
    if (percent.value >= 70) {
      clearInterval(timer)
    }
  }, 200)
})
</script>
