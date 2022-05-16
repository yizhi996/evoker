<template>
  <n-topic>小球{{ appear ? "" : "未" }}出现</n-topic>
  <scroll-view id="scroll-view" class="h-52" scroll-y>
    <div
      class="flex flex-col items-center duration-500"
      :style="{ height: '800px', 'background-color': appear ? '#ccc' : '#fff' }"
    >
      <span class="mt-20">向下滚动让小球出现</span>
      <div class="h-48"></div>
      <div class="w-24 h-24 rounded-full bg-orange-400" id="ball"></div>
    </div>
  </scroll-view>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue"

const observer = nz.createIntersectionObserver()

const appear = ref(false)

onMounted(() => {
  observer.relativeTo("#scroll-view").observe("#ball", res => {
    appear.value = res.isIntersecting
  })
})
</script>
