<template>
  <div class="flex items-center min-h[44px] border-b last:border-none p-3">
    <span class="flex-shrink-0 w-16 mr-3">{{ label }}</span>
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
defineProps<{ label: string }>()
</script>
