<template>
  <n-topic>请截屏</n-topic>
  <div class="flex items-center justify-center bg-white py-10 text-2xl">
    截屏事件{{ captured ? "已触发" : "未触发" }}
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue"

const captured = ref(false)

onMounted(() => {
  ek.onUserCaptureScreen(onCapture)
})

onUnmounted(() => {
  ek.offUserCaptureScreen(onCapture)
})

const onCapture = () => {
  captured.value = true
}
</script>
