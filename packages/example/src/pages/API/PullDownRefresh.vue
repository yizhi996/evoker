<template>
  <div class="flex flex-col items-center justify-center w-full h-full">
    <span class="mt-5">下滑页面即可刷新</span>
    <button class="mt-20" @click="onStop">停止刷新</button>
  </div>
</template>

<script setup lang="ts">
import { usePage } from "evoker"

const { onPullDownRefresh } = usePage()

onPullDownRefresh(() => {
  ek.showToast({ title: "Loading...", icon: "none" })
})

const onStop = () => {
  ek.stopPullDownRefresh()
}
</script>
