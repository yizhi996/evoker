<template>
  <div class="w-full flex flex-col items-center mt-5">
    <movable-area class="w-40 h-40 bg-gray-300">
      <movable-view
        class="bg-blue-400 w-12 h-12 flex items-center justify-center target"
        v-model:x="position.x"
        v-model:y="position.y"
        @change="getNodeInfo"
        >Drag</movable-view
      >
    </movable-area>
    <div class="flex flex-col mt-5 w-1/2">
      <div v-for="(value, name) in rect" :key="name" class="flex justify-between">
        <span>{{ name }}</span>
        <span>{{ value }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import { usePage } from "evoker"

const { onReady } = usePage()

const position = reactive({ x: 0, y: 0 })

let rect = reactive({ left: 0, right: 0, top: 0, bottom: 0, width: 0, height: 0 })

onReady(() => {
  getNodeInfo()
})

const getNodeInfo = () => {
  const query = ek.createSelectorQuery()
  query
    .select(".target")
    .boundingClientRect(res => {
      rect.left = res.left
      rect.right = res.right
      rect.top = res.top
      rect.bottom = res.bottom
      rect.width = res.width
      rect.height = res.height
    })
    .exec()
}
</script>
