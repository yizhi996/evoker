<template>
  <div class="w-full flex flex-col">
    {{ value1 }}
    <slider v-model="value1" :step="10"></slider>
    <slider v-model="value2"></slider>
    <slider v-model="value3" :min="50" :max="200"></slider>

    <button @click="setValue">Change</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value1 = ref(50)
const value2 = ref(50)
const value3 = ref(50)

const setValue = () => {
  value1.value = 80
  value2.value = 80
  value3.value = 80
}
</script>