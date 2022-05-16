<template>
  <nz-swiper-item ref="containerRef" :style="style">
    <slot></slot>
  </nz-swiper-item>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, getCurrentInstance, onUnmounted } from "vue"
import { SWIPE_KEY, SwipeProvide } from "./constant"
import { useParent, ParentProvide } from "../../use/useRelation"

const instance = getCurrentInstance()!
const containerRef = ref<HTMLElement>()
let parent: ParentProvide<SwipeProvide> | undefined

onMounted(() => {
  setTimeout(() => {
    parent = useParent(instance, SWIPE_KEY)
  })
})

onUnmounted(() => {
  parent && parent.unlink(instance)
})

let style = reactive<{ width?: string; height?: string; transform?: string }>({})

defineExpose({
  setStyle: (width: string, height: string, transform: string) => {
    style.width = width
    style.height = height
    style.transform = transform
  },
  setSize: (width: string, height: string) => {
    style.width = width
    style.height = height
  },
  setTransform: (transform: string) => {
    style.transform = transform
  }
})
</script>

<style>
nz-swiper-item {
  display: block;
  overflow: hidden;
  width: 100%;
  height: 100%;
  will-change: transform;
  position: absolute;
}
</style>
