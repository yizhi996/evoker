<template>
  <van-cell-group :title="'扫码结果: ' + type">
    <van-cell class="break-all min-h-10" :value="result" />
  </van-cell-group>
  <button type="primary" @click="toScan">扫一扫</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const result = ref("")
const type = ref("")

const toScan = () => {
  nz.scanCode().then(res => {
    result.value = res.result
    type.value = res.scanType
  })
}
</script>
