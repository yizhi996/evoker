<template>
  <nz-navigator v-tap.stop="invoke">
    <slot></slot>
  </nz-navigator>
</template>

<script setup lang="ts">
import { vTap } from "../directive/tap"
import {
  navigateTo,
  redirectTo,
  switchTab,
  reLaunch,
  navigateBack,
  navigateToMiniProgram,
  exit
} from "../../bridge"

const props = withDefaults(defineProps<{
  target?: "self" | "miniProgram"
  url?: string
  openType?: "navigate" | "redirect" | "switchTab" | "reLaunch" | "navigateBack" | "exit"
  delta?: number
  appId?: string
  path?: string
}>(), {
  target: "self",
  openType: "navigate",
  delta: 1
})

const invoke = () => {
  if (props.target === "self") {
    switch (props.openType) {
      case "navigate":
        navigateTo(props.url)
        break
      case "redirect":
        redirectTo(props.url)
        break
      case "switchTab":
        switchTab(props.url)
        break
      case "reLaunch":
        reLaunch(props.url)
        break
      case "navigateBack":
        navigateBack(props.delta)
        break
    }
  } else if (props.target === "miniProgram") {
    if (props.openType === "navigate") {
      if (props.appId) {
        navigateToMiniProgram({ appId: props.appId, path: props.path })
      }
    } else if (props.openType === "exit") {
      exit()
    } else {
      console.warn("target required: miniProgram")
    }
  }
}
</script>

<style>
nz-navigator {
  display: block;
  height: auto;
  width: auto;
}
</style>
