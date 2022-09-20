<template>
  <n-cell-group>
    <n-cell title="手机品牌">{{ systemInfo.brand }}</n-cell>
    <n-cell title="手机型号">{{ systemInfo.model }}</n-cell>
    <n-cell title="宿主语言">{{ systemInfo.language }}</n-cell>
    <n-cell title="宿主版本">{{ systemInfo.version }}</n-cell>
    <n-cell title="屏幕宽度">{{ systemInfo.screenWidth }}</n-cell>
    <n-cell title="屏幕高度">{{ systemInfo.screenHeight }}</n-cell>
    <n-cell title="DPR">{{ systemInfo.pixelRatio }}</n-cell>
  </n-cell-group>
  <button type="primary" @click="onClick">获取手机系统信息</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const systemInfo = ref({})

const onClick = async () => {
  const res = await ek.getSystemInfo()
  systemInfo.value = res
}
</script>
