<template>
  <nz-movable-area ref="areaRef"></nz-movable-area>
</template>

<script setup lang="ts">
import { ref, watch } from "vue"
import { useChildren } from "../../use/useRelation"
import { MOVABLE_KEY } from "./constant"

const areaRef = ref<HTMLElement>()

const { children, linkChildren } = useChildren(MOVABLE_KEY)

linkChildren({})

watch(
  () => [...children],
  children => {
    const rect = areaRef.value?.getBoundingClientRect()
    children.forEach(child => {
      child.exposed!.setAreaRect(rect)
    })
  }
)
</script>

<style>
nz-movable-area {
  display: block;
  position: relative;
  width: 10px;
  height: 10px;
}
</style>
