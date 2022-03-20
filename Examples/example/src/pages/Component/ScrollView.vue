<template>
  <div class="mx-5">
    <topic>Vertical Scroll</topic>
    <scroll-view
      scroll-y
      class="w-full h-36"
      :scroll-top="scrollTop"
      :scroll-into-view="scrollIntoView"
      enhanced
      scroll-with-animation
      @scroll="onScroll"
    >
      <div id="green" class="w-full h-36 bg-green-500"></div>
      <div id="blue" class="w-full h-36 bg-blue-500"></div>
      <div id="gray" class="w-full h-36 bg-gray-300"></div>
    </scroll-view>

    <button type="primary" @click="toNext">Next</button>
    <button type="success" @click="incScrollTop">Move</button>

    <topic>Horizontal Scroll</topic>
    <div class="flex justify-center">
      <scroll-view scroll-x class="w-full h-36 whitespace-nowrap">
        <div class="inline-block w-full h-36 bg-green-500"></div>
        <div class="inline-block w-full h-36 bg-blue-500"></div>
        <div class="inline-block w-full h-36 bg-gray-300"></div>
      </scroll-view>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const scrollTop = ref(0)
const scrollIntoView = ref("")
const items = ["green", "blue", "gray"]
let idx = 0

const incScrollTop = () => {
  scrollTop.value += 44
}

const toNext = () => {
  idx += 1
  if (idx > items.length - 1) {
    idx = 0
  }
  scrollIntoView.value = items[idx]
}

const onScroll = (object: any) => {
  scrollTop.value = object.scrollTop
}

</script>
