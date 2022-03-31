<template>
  <topic>网络状态</topic>
  <div class="flex items-center justify-center bg-white py-10 text-2xl">{{ networkType }}</div>
  <button type="primary" @click="onClick">获取手机网络状态</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const networkType = ref("未获取")

const onClick = async () => {
  const res = await nz.getNetworkType()
  networkType.value = res.networkType
}
</script>