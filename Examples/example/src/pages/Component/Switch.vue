<template>
  <div class="flex flex-col items-center mt-5">
    <span>选中</span>
    <switch :checked="value1" @change="onChange"></switch>
    <span>未选中</span>
    <switch v-model:checked="value2"></switch>
    <span>禁用</span>
    <switch v-model:checked="value3" disabled></switch>
    <span>自定义颜色</span>
    <switch v-model:checked="value4" color="#07c160"></switch>
    <button @click="onSwitch">点击切换</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value1 = ref(true)
const value2 = ref(false)
const value3 = ref(true)
const value4 = ref(true)

const onChange = (newValue: boolean) => {
  value1.value = newValue
}

const onSwitch = () => {
  value1.value = !value1.value
}
</script>
