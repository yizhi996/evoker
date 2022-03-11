<template>
  <div class="w-full flex flex-col items-center justify-center mt-5">
    <button type="primary" @click="onShow">显示加载动画</button>
    <button class="mt-2.5" type="primary" @click="onHide">隐藏加载动画</button>
  </div>
</template>

<script setup lang="ts">

const onShow = () => {
  nz.showNavigationBarLoading()
}

const onHide = () => {
  nz.hideNavigationBarLoading()
}
</script>