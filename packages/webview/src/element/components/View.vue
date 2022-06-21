<template>
  <nz-view ref="el" :class="finalHoverClass"></nz-view>
</template>

<script setup lang="ts">
import { ref } from "vue"
import useHover from "../use/useHover"
import { useCSSAnimation, AnimationAction } from "../use/useCSSAnimation"

const props = withDefaults(
  defineProps<{
    hoverClass?: string
    hoverStopPropagation?: boolean
    hoverStartTime?: number
    hoverStayTime?: number
    animation?: AnimationAction[]
  }>(),
  {
    hoverClass: "none",
    hoverStopPropagation: false,
    hoverStartTime: 50,
    hoverStayTime: 400,
    animation: () => []
  }
)

const el = ref<HTMLElement>()

const { finalHoverClass } = useHover(el, props)

useCSSAnimation(el, props)
</script>

<style>
nz-view {
  display: block;
}

.nz-button--hover {
  box-shadow: inset 0 0 100px 100px rgba(0, 0, 0, 0.1);
}
</style>
