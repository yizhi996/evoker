<template>
  <button type="primary" @click="onScrollToBottom">滚动到底部</button>
  <div style="width: 100%; height: 2000px"></div>
  <button type="primary" @click="onScrollToTop">返回顶部</button>
</template>

<script setup lang="ts">
const onScrollToBottom = () => {
  ev.pageScrollTo({
    scrollTop: 3000
  })
}

const onScrollToTop = () => {
  ev.pageScrollTo({
    scrollTop: 0
  })
}
</script>
