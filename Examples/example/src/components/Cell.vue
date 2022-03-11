<template>
  <div class="flex items-top border-b last:border-none py-3">
    <span class="flex-shrink-0 mr-2.5 w-20 text-left">{{ title }}</span>
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title?: string
}>()
</script>