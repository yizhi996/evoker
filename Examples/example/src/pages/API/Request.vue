<template>
  <div class="mx-2.5 mt-2.5">
    <input class="w-full h-10 bg-white" v-model:value="url" placeholder="url..." />
    <button class="mt-2.5" type="primary" @click="onRequest">request</button>
    <n-topic>Response Header</n-topic>
    <n-object :object="header" placeholder="Response Header"></n-object>
    <n-topic>Response Data</n-topic>
    <n-object class="mt-2.5" :object="result" placeholder="Response Data"></n-object>
  </div>
</template>

<script setup lang="ts">
import { useLocalStore } from "../../store"
import { ref } from "vue"

const { getDeviceId } = useLocalStore()

const url = ref("https://lilithvue.com/api/test")
const result = ref<Record<string, any>>({})
const header = ref<Record<string, string>>({})

const onRequest = async () => {
  const deviceId = await getDeviceId()

  nz.request({
    url: url.value,
    method: "POST",
    data: { deviceId },
    success: res => {
      result.value = res.data
      header.value = res.header
    },
    fail: err => {
      result.value = err
      header.value = {}
    }
  })
}
</script>
