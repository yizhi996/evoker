<template>
  <nz-loading :style="{ width: finalSize, height: finalSize, color: color }">
    <svg class="nz-loading__circle" viewBox="25 25 50 50">
      <circle cx="50" cy="50" r="20" fill="none" />
    </svg>
  </nz-loading>
</template>

<script setup lang="ts">
import { computed } from "vue"
import { unitToPx } from "../utils/format"

const props = withDefaults(
  defineProps<{
    size?: number | string
    color?: string
  }>(),
  {
    size: 20,
    color: "white"
  }
)

const finalSize = computed(() => {
  return unitToPx(props.size) + "px"
})
</script>

<style lang="less">
nz-loading {
  display: inline-block;
  position: relative;
  animation: rotate 2s linear infinite;
}

.nz-loading__circle {
  display: block;
  width: 100%;
  height: 100%;

  > circle {
    stroke: currentColor;
    stroke-width: 3;
    stroke-linecap: round;
    animation: circular 1.5s ease-in-out infinite;
  }
}

@keyframes rotate {
  0% {
    transform: rotate(0);
  }

  to {
    transform: rotate(360deg);
  }
}

@keyframes circular {
  0% {
    stroke-dasharray: 1, 200;
    stroke-dashoffset: 0;
  }

  50% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -40;
  }

  to {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -120;
  }
}
</style>
