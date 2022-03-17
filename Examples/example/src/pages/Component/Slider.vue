<template>
  <div class="w-full flex flex-col">
    <slider :value="value1" :step="10"></slider>
    <slider :value="value2" show-value></slider>
    <slider :value="value3" :min="50" :max="200" show-value></slider>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value1 = ref(50)
const value2 = ref(50)
const value3 = ref(50)


</script>