<template>
  <div class="flex flex-col items-center justify-center w-full h-full">
    <span class="mt-5">下滑页面即可刷新</span>
    <button class="mt-20" @click="onStop">停止刷新</button>
  </div>
</template>

<script setup lang="ts">
import { usePage } from "nzoth"

const { onPullDownRefresh } = usePage()

onPullDownRefresh(() => {
  nz.showToast({ title: "Loading...", icon: "none" })
})

const onStop = () => {
  nz.stopPullDownRefresh()
}
</script>
