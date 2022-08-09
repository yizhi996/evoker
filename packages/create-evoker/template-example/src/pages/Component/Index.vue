<template>
  <n-page-index desc="以下将展示小程序内置组件，部分组件还未完善功能" :list="list"></n-page-index>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import { usePage } from "evoker"
import NPageIndex from "../../components/NPageIndex.vue"

const list = reactive([
  {
    id: "view",
    name: "视图容器",
    open: false,
    pages: [
      { name: "view", url: "./View" },
      { name: "scroll-view", url: "./ScrollView" },
      { name: "swiper", url: "./Swiper" },
      { name: "movable-view", url: "./Movable" }
    ]
  },
  {
    id: "content",
    name: "基础内容",
    open: false,
    pages: [
      { name: "text", url: "./Text" },
      { name: "icon", url: "./Icon" },
      { name: "progress", url: "./Progress" }
    ]
  },
  {
    id: "form",
    name: "表单组件",
    open: false,
    pages: [
      { name: "button", url: "./Button" },
      { name: "checkbox", url: "./Checkbox" },
      { name: "form", url: "./Form" },
      { name: "input", url: "./Input" },
      { name: "label", url: "./Label" },
      { name: "picker", url: "./Picker" },
      { name: "picker-view", url: "./PickerView" },
      { name: "radio", url: "./Radio" },
      { name: "slider", url: "./Slider" },
      { name: "switch", url: "./Switch" },
      { name: "textarea", url: "./Textarea" }
    ]
  },
  {
    id: "nav",
    name: "导航",
    open: false,
    pages: [{ name: "navigator", url: "./Navigator" }]
  },
  {
    id: "media",
    name: "媒体组件",
    open: false,
    pages: [
      { name: "image", url: "./Image" },
      { name: "video", url: "./Video" },
      { name: "camera", url: "./Camera" }
    ]
  },
  {
    id: "map",
    name: "地图",
    open: false,
    pages: [{ name: "map", url: "./Map" }]
  },
  {
    id: "canvas",
    name: "画布",
    open: false,
    pages: [
      { name: "canvas-2d", url: "./Canvas" },
      { name: "webgl 暂未支持", url: "./Webgl" }
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
