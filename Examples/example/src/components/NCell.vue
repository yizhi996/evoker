<template>
  <div class="flex items-top border-b last:border-none py-3">
    <span v-if="title" class="flex-shrink-0 mr-2.5 w-24 text-left">{{ title }}</span>
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title?: string
}>()
</script>
