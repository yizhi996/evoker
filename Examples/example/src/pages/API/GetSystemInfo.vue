<template>
  <cell-group>
    <cell title="手机品牌">{{ systemInfo.brand }}</cell>
    <cell title="手机型号">{{ systemInfo.model }}</cell>
    <cell title="宿主语言">{{ systemInfo.language }}</cell>
    <cell title="宿主版本">{{ systemInfo.version }}</cell>
    <cell title="屏幕宽度">{{ systemInfo.screenWidth }}</cell>
    <cell title="屏幕高度">{{ systemInfo.screenHeight }}</cell>
    <cell title="DPR">{{ systemInfo.pixelRatio }}</cell>
  </cell-group>
  <button type="primary" @click="onClick">获取手机系统信息</button>
</template>

<script setup lang="ts">
import { ref } from "vue"
import CellGroup from "../../components/CellGroup.vue"
import Cell from "../../components/Cell.vue"

const systemInfo = ref({})

const onClick = async () => {
  const res = await nz.getSystemInfo()
  systemInfo.value = res
}
</script>