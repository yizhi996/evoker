<template>
  <nz-view ref="viewRef" :class="finalHoverClass">
    <slot></slot>
  </nz-view>
</template>

<script setup lang="ts">
import { ref } from "vue"
import useHover from "../use/useHover"
import useCSSAnimation from "../use/useCSSAnimation"
import type { AnimationAction } from "../use/useCSSAnimation"

const props = withDefaults(defineProps<{
  hoverClass?: string
  hoverStopPropagation?: boolean
  hoverStartTime?: number
  hoverStayTime?: number
  animation?: AnimationAction[]
}>(), {
  hoverClass: "none",
  hoverStopPropagation: false,
  hoverStartTime: 50,
  hoverStayTime: 400,
  animation: () => []
})

const viewRef = ref<HTMLElement>()

const { finalHoverClass } = useHover(viewRef, props)

useCSSAnimation(viewRef, props)

</script>

<style>
nz-view {
  display: block;
}

.nz-button--hover {
  box-shadow: inset 0 0 100px 100px rgba(0, 0, 0, 0.1);
}
</style>
