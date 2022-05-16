<template>
  <button @click="setTabBarBadge">
    {{ isSetTabBarBadge ? "移除 tab 徽标" : "设置 tab 徽标" }}
  </button>
  <button @click="showTabBarRedDot">
    {{ isShowTabBarRedDot ? "隐藏红点" : "显示红点" }}
  </button>
  <button @click="setTabBarStyle">
    {{ isSetTabBarStyle ? "移除自定义 tab 样式" : "自定义 tab 样式" }}
  </button>
  <button @click="setTabBarItem">
    {{ isSetTabBarItem ? "移除自定义 tab 信息" : "自定义 tab 信息" }}
  </button>
  <button @click="hideTabBar">
    {{ isShowTabBar ? "显示 TabBar" : "隐藏 TabBar" }}
  </button>
  <button type="primary" @click="onClose">返回</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const emit = defineEmits(["close"])

const isSetTabBarBadge = ref(false)

const setTabBarBadge = () => {
  if (isSetTabBarBadge.value) {
    isSetTabBarBadge.value = false
    nz.removeTabBarBadge({ index: 2 })
  } else {
    isSetTabBarBadge.value = true
    nz.setTabBarBadge({
      index: 2,
      text: "1"
    })
  }
}

const isShowTabBarRedDot = ref(false)

const showTabBarRedDot = () => {
  if (isShowTabBarRedDot.value) {
    isShowTabBarRedDot.value = false
    nz.hideTabBarRedDot({ index: 2 })
  } else {
    isShowTabBarRedDot.value = true
    nz.showTabBarRedDot({ index: 2 })
  }
}

const isSetTabBarStyle = ref(false)

const setTabBarStyle = () => {
  if (isSetTabBarStyle.value) {
    isSetTabBarStyle.value = false
    nz.setTabBarStyle({
      color: "#86868b",
      selectedColor: "#1989fa",
      backgroundColor: "#ffffff"
    })
  } else {
    isSetTabBarStyle.value = true
    nz.setTabBarStyle({
      color: "#fff",
      selectedColor: "#1989fa",
      backgroundColor: "#000"
    })
  }
}

const isSetTabBarItem = ref(false)

const setTabBarItem = () => {
  if (isSetTabBarItem.value) {
    isSetTabBarItem.value = false
    nz.setTabBarItem({ index: 2, text: "接口", selectedIconPath: "assets/icon_API_HL.png" })
  } else {
    isSetTabBarItem.value = true
    nz.setTabBarItem({
      index: 2,
      text: "API",
      selectedIconPath:
        "https://file.lilithvue.com/lilith-test-assets/wallhaven-43y68y.jpg?imageMogr2/thumbnail/81x"
    })
  }
}

const isShowTabBar = ref(false)

const hideTabBar = () => {
  if (isShowTabBar.value) {
    isShowTabBar.value = false
    nz.showTabBar({})
  } else {
    isShowTabBar.value = true
    nz.hideTabBar({})
  }
}

const onClose = () => {
  emit("close")
}
</script>
