<template>
  <n-page-index desc="以下将展示小程序内置组件，部分组件还未完善功能" :list="list"></n-page-index>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import { usePage } from "nzoth"
import NPageIndex from "../../components/NPageIndex.vue"

const list = reactive([
  {
    id: "view",
    name: "视图容器",
    open: false,
    pages: [{ url: "view" }, { url: "scroll-view" }, { url: "swiper" }, { url: "movable-view" }]
  },
  {
    id: "content",
    name: "基础内容",
    open: false,
    pages: [{ url: "text" }, { url: "icon" }, { url: "progress" }]
  },
  {
    id: "form",
    name: "表单组件",
    open: false,
    pages: [
      { url: "button" },
      { url: "checkbox" },
      { url: "form" },
      { url: "input" },
      { url: "label" },
      { url: "picker" },
      { url: "picker-view" },
      { url: "radio" },
      { url: "slider" },
      { url: "switch" },
      { url: "textarea" }
    ]
  },
  {
    id: "nav",
    name: "导航",
    open: false,
    pages: [{ url: "navigator" }]
  },
  {
    id: "media",
    name: "媒体组件",
    open: false,
    pages: [{ url: "image" }, { url: "video" }, { url: "camera" }]
  },
  {
    id: "map",
    name: "地图",
    open: false,
    pages: [{ url: "map" }]
  },
  {
    id: "canvas",
    name: "画布",
    open: false,
    pages: [
      { name: "canvas-2d 暂未支持", url: "canvas-2d" },
      { name: "webgl 暂未支持", url: "webgl" }
    ]
  }
])

const { onLoad, onShow, onReady, onHide, onUnload } = usePage()

onLoad(options => {
  console.log("Page onLoad: ", options)
})

onShow(() => {
  console.log("Page onShow")
})

onReady(() => {
  console.log("Page onReady")
})

onHide(() => {
  console.log("Page onHide")
})

onUnload(() => {
  console.log("Page onUnload")
})
</script>
