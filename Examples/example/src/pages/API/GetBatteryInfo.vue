<template>
  <n-cell-group class="m-2.5">
    <n-cell title="当前电量">{{ info.level }}</n-cell>
    <n-cell title="电池模式">{{ info.isCharging }}</n-cell>
  </n-cell-group>
  <button type="primary" @click="getBatteryInfo">获取电池信息</button>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import NCellGroup from '../../components/NCellGroup.vue'
import NCell from '../../components/NCell.vue'

const info = reactive({
  level: "未获取",
  isCharging: "未获取"
})

const getBatteryInfo = async () => {
  const res = await nz.getBatteryInfo()
  info.level = res.level + ""
  info.isCharging = res.isCharging ? "充电中" : "使用电池中"
}
</script>