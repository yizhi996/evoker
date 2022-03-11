<template>
  <nz-text>
    <span class="nz-text-content">
      <slot></slot>
    </span>
  </nz-text>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  userSelect?: boolean
}>(), {
  userSelect: false
})

</script>

<style>
nz-text {
  cursor: text;
} 
</style>