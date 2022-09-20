<template>
  <button @click="navigateTo">跳转新页面</button>
  <button @click="navigateBack">返回上一页</button>
  <button @click="redirectTo">在当前页面打开</button>
  <button @click="switchTab">跳转到组件 Tab 页</button>
  <button @click="reLaunch">关闭所有页面并跳转</button>
</template>

<script setup lang="ts">
const navigateTo = () => {
  ek.navigateTo({ url: "./Navigator" })
}

const navigateBack = () => {
  ek.navigateBack({})
}

const redirectTo = () => {
  ek.redirectTo({ url: "./Navigator" })
}

const switchTab = () => {
  ek.switchTab({ url: "../components/Index" })
}

const reLaunch = () => {
  ek.reLaunch({ url: "../components/Index" })
}
</script>
