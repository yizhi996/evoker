<template>
  <div class="mx-2.5 mt-2.5">
    <topic>isFocus: {{ focus }}</topic>
    <textarea
      class="w-full h-14 bg-white"
      value="NZoth"
      placeholder="请输入..."
      focus
      @focus="onFocus"
      @blur="onBlur"
    />

    <topic>Auto Height</topic>
    <textarea
      class="w-full bg-white"
      value=""
      :maxlength="0"
      auto-height
      placeholder="请输入..."
    />

    <topic>Custom Style</topic>
    <textarea
      class="w-full h-20 bg-white text-red-400 text-xl font-light"
      placeholder="请输入"
      placeholder-class="text-blue-400 text-xl font-light"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const focus = ref(true)

const onFocus = () => {
  focus.value = true
}

const onBlur = () => {
  focus.value = false
}

</script>
