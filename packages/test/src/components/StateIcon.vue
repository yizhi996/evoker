<template>
  <icon :type="type"></icon>
</template>

<script setup lang="ts">
import { computed } from "vue"

const props = defineProps<{ state: number }>()

const type = computed(() => {
  switch (props.state) {
    case 0:
      return "circle"
    case 1:
      return "waiting"
    case 2:
      return "success"
    case 3:
      return "warn"
  }
})
</script>
