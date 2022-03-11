<template>
  <nz-view ref="viewRef" :class="finalHoverClass">
    <slot></slot>
  </nz-view>
</template>

<script setup lang="ts">
import useHover from "../use/useHover"

const props = withDefaults(defineProps<{
  hoverClass?: string
  hoverStopPropagation?: boolean
  hoverStartTime?: number
  hoverStayTime?: number
}>(), {
  hoverClass: "none",
  hoverStopPropagation: false,
  hoverStartTime: 50,
  hoverStayTime: 400
})

const { viewRef, finalHoverClass } = useHover(props)

</script>

<style>
nz-view {
  display: block;
}

.nz-button--hover {
  box-shadow: inset 0 0 100px 100px rgba(0, 0, 0, 0.1);
}
</style>
