<template>
  <div class="flex flex-col items-center bg-blue-500 p-5">
    <div class="text-white">Custom Component</div>
    <button @click="onChange">Inner Change</button>
    <div>Text: {{ modelValue }}</div>
  </div>
</template>

<script setup lang="ts">

const emit = defineEmits(["update:modelValue"])

defineProps<{
  modelValue: string
}>()

const onChange = () => {
  emit("update:modelValue", "INNER")
}
</script>