<template>
  <div class="mx-5">
    <div>movable-view 小于 movable-area</div>
    <div>x: {{ position.x }} y: {{ position.y }}</div>
    <div class="mt-5 w-full flex flex-col items-center justify-center">
      <movable-area class="w-48 h-48 bg-gray-300">
        <movable-view
          class="bg-blue-400 w-12 h-12 flex items-center justify-center text-xl"
          v-model:x="position.x"
          v-model:y="position.y"
        >😅</movable-view>
      </movable-area>
      <button type="primary" @click="onMove">点击移动到(30px, 30px)</button>
    </div>
    <span>只可以水平移动</span>
    <div class="mt-5 w-full flex items-center justify-center">
      <movable-area class="w-48 h-48 bg-gray-300">
        <movable-view
          class="bg-blue-400 w-12 h-12 flex items-center justify-center text-xl"
          direction="horizontal"
        >😅</movable-view>
      </movable-area>
    </div>
    <span>只可以垂直移动</span>
    <div class="mt-5 w-full flex items-center justify-center">
      <movable-area class="w-48 h-48 bg-gray-300">
        <movable-view
          class="bg-blue-400 w-12 h-12 flex items-center justify-center text-xl"
          direction="vertical"
        >😅</movable-view>
      </movable-area>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue"

const position = reactive({ x: 5, y: 5 })

const onMove = () => {
  position.x = 30
  position.y = 30
}

</script>
