<template>
  <div class="bg-white flex items-center px-2.5 w-full mt-5 h-11">
    <div class="flex-shrink-0">页面标题</div>
    <input class="ml-2.5" v-model="title" placeholder="请输入页面标题" />
  </div>
  <button type="primary" @click="onSetTitle">设置</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const title = ref("")

const onSetTitle = () => {
  nz.setNavigationBarTitle({ title: title.value })
} 
</script>