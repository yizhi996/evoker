<template>
  <nz-swiper-item ref="containerRef">
    <slot></slot>
  </nz-swiper-item>
</template>

<script setup lang="ts">
import { ref, onMounted, getCurrentInstance, onUnmounted } from "vue"
import { SWIPE_KEY } from "./constant"
import { useParent } from "../../use/useRelation"

const instance = getCurrentInstance()!
const containerRef = ref<HTMLElement>()
let parent: any

onMounted(() => {
  setTimeout(() => {
    parent = useParent(instance, SWIPE_KEY).parent
  })
})

onUnmounted(() => {
  parent && parent.unlink(instance)
})

</script>

<style>
nz-swiper-item {
  display: block;
  overflow: hidden;
  width: 100%;
  height: 100%;
}
</style>
