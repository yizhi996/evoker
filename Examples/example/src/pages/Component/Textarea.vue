<template>
  <div class="mx-3 mt-3">auth focus</div>
  <div class="mx-3 flex items-center relative">
    <textarea class="w-full bg-white" v-model="value" placeholder="请输入..." focus />
  </div>
  <div class="mx-3 mt-3">auto height</div>
  <div class="mx-3 flex items-center relative">
    <textarea
      class="w-full h-12 text-red-500 bg-red-50 text-lg"
      v-model="value2"
      :maxlength="-1"
      auto-height
      placeholder="请输入..."
      placeholder-class="text-red-300"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value = ref("")
const value2 = ref("")

</script>
