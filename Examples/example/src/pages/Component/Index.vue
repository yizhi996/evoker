<template>
  <page-index desc="以下将展示小程序内置组件，部分组件还未完善功能" :list="list"></page-index>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import { usePage } from "nzoth"
import PageIndex from "../../components/PageIndex.vue"

const list = reactive([
  {
    id: "view",
    name: "视图容器",
    open: false,
    pages: [
      { name: "view", url: "view" },
      { name: "scroll-view", url: "scroll-view" },
      { name: "swiper", url: "swiper" },
      { name: "movable-view", url: "movable-view" }]
  }, {
    id: "content",
    name: "基础内容",
    open: false,
    pages: [
      { name: "text", url: "text" },
      { name: "icon", url: "icon" },
      { name: "progress", url: "progress" }]
  }, {
    id: "form",
    name: "表单组件",
    open: false,
    pages: [{ name: "button", url: "button" },
    { name: "checkbox", url: "checkbox" },
    { name: "form", url: "form" },
    { name: "input", url: "input" },
    { name: "label", url: "label" },
    { name: "picker", url: "picker" },
    { name: "picker-view", url: "picker-view" },
    { name: "radio", url: "radio" },
    { name: "slider", url: "slider" },
    { name: "switch", url: "switch" },
    { name: "textarea", url: "textarea" }]
  }, {
    id: "nav",
    name: "导航",
    open: false,
    pages: [{ name: "navigator", url: "navigator" }]
  }, {
    id: "media",
    name: "媒体组件",
    open: false,
    pages: [{ name: "image", url: "image" },
    { name: "video", url: "video" },
    { name: "camera", url: "camera" }]
  }, {
    id: "map",
    name: "地图",
    open: false,
    pages: [{ name: "map", url: "map" }]
  }, {
    id: "canvas",
    name: "画布",
    open: false,
    pages: [
      { name: "canvas-2d 暂未支持", url: "canvas-2d" },
      { name: "webgl 暂未支持", url: "webgl" }]
  }, {
    id: "open",
    name: "开放能力",
    open: false,
    pages: [{ name: "web-view", url: "web-view" }]
  }, {
    id: "obstacle-free",
    name: "无障碍访问",
    open: false,
    pages: [{ name: "aria-component", url: "aria-component" }]
  }
])

const { onLoad, onShow, onReady, onHide } = usePage()

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

</script>
