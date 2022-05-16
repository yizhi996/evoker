<template>
  <div class="flex flex-col items-center justify-center space-y-3">
    <button @click="showToast">点击弹出默认 toast</button>
    <button @click="showToastThreeSeconds">点击弹出设置 duration 的 toast</button>
    <button @click="showToastLoading">点击弹出显示 loading 的 toast</button>
    <button @click="hideToast">点击隐藏 toast</button>
  </div>
</template>

<script setup lang="ts">
const showToast = () => {
  nz.showToast({ title: "默认" })
}

const showToastThreeSeconds = () => {
  nz.showToast({
    title: "duration 3000",
    duration: 3000
  })
}

const showToastLoading = () => {
  nz.showToast({
    title: "loading",
    icon: "loading",
    duration: 5000
  })
}

const hideToast = () => {
  nz.hideToast()
}
</script>
