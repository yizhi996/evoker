<template>
  <button type="primary" @click="onScrollToBottom">滚动到底部</button>
  <div style="width: 100%;height: 2000px;"></div>
  <button type="primary" @click="onScrollToTop">返回顶部</button>
</template>

<script setup lang="ts">
const onScrollToBottom = () => {
  nz.pageScrollTo({
    scrollTop: 3000
  })
}

const onScrollToTop = () => {
  nz.pageScrollTo({
    scrollTop: 0
  })
}
</script>