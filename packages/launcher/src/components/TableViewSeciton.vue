<template>
  <div class="ml-3 text-gray-400">{{ title }}</div>
  <div class="mt-3 flex flex-col bg-white">
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
defineProps<{ title?: string }>()
</script>
