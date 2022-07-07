<template>
  <div>
    <n-topic>当前屏幕亮度</n-topic>
    <div class="flex items-center justify-center py-10 bg-white text-4xl">{{ brightness }}</div>
    <n-topic>设置屏幕亮度</n-topic>
    <slider
      class="mt-10"
      :value="brightness"
      :min="0"
      :max="1"
      :step="0.1"
      @change="onChange"
    ></slider>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const brightness = ref(0)

const getScreenBrightness = async () => {
  const res = await ek.getScreenBrightness()
  brightness.value = res.value.toFixed(1)
}

getScreenBrightness()

const onChange = e => {
  const value = e.detail.value
  brightness.value = value.toFixed(1)
  ek.setScreenBrightness({ value: brightness.value })
}
</script>
