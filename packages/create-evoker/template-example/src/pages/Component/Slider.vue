<template>
  <div class="w-full flex flex-col">
    <n-topic>step: 10</n-topic>
    <slider :value="value1" :step="10"></slider>
    <n-topic>show value</n-topic>
    <slider :value="value2" show-value></slider>
    <n-topic>min: 50, max: 200</n-topic>
    <slider :value="value3" :min="50" :max="200" show-value></slider>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value1 = ref(50)
const value2 = ref(50)
const value3 = ref(50)
</script>
