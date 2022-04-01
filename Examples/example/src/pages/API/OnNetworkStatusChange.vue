<template>
  <n-topic>网络状态</n-topic>
  <div class="flex items-center justify-center bg-white py-10 text-2xl">{{ networkType }}</div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue"

const networkType = ref("")

onMounted(async () => {
  const res = await nz.getNetworkType()
  networkType.value = res.networkType
  nz.onNetworkStatusChange(onChange)
})

onUnmounted(() => {
  nz.offNetworkStatusChange(onChange)
})

const onChange = ({ networkType: _networkType }) => {
  networkType.value = _networkType
}
</script>