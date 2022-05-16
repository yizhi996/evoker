<template>
  <n-page-index
    desc="以下组件使用 Vant Vue 版本，展示引入现有开源 UI 库的能力"
    :list="list"
  ></n-page-index>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import NPageIndex from "../../components/NPageIndex.vue"

const list = reactive([
  {
    id: "view",
    name: "基础组件",
    open: false,
    pages: [
      {
        name: "Icon",
        url: "extension/icon"
      }
    ]
  }
])
</script>
