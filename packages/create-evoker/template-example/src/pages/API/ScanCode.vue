<template>
  <n-cell-group>
    <n-cell class="break-all min-h-10" title="扫码结果">{{ result }}</n-cell>
  </n-cell-group>
  <button type="primary" @click="toScan">扫一扫</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const result = ref("")

const toScan = () => {
  ek.scanCode().then(res => {
    result.value = res.result
  })
}
</script>
