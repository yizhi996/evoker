<template>
  <button @click="navigateTo">跳转新页面</button>
  <button @click="navigateBack">返回上一页</button>
  <button @click="redirectTo">在当前页面打开</button>
  <button @click="switchTab">跳转到组件 Tab 页</button>
  <button @click="reLaunch">关闭所有页面并跳转</button>
</template>

<script setup lang="ts">
const navigateTo = () => {
  nz.navigateTo({ url: "api/navigator" })
}

const navigateBack = () => {
  nz.navigateBack({})
}

const redirectTo = () => {
  nz.redirectTo({ url: "api/navigator" })
}

const switchTab = () => {
  nz.switchTab({ url: "component" })
}

const reLaunch = () => {
  nz.reLaunch({ url: "component" })
}
</script>
