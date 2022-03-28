<template>
  <div class="mx-2.5 mt-2.5">
    <input class="w-full h-10 bg-white" v-model:value="url" placeholder="url..." />
    <button class="mt-2.5" type="primary" @click="onRequest">request</button>
    <n-object :object="header" placeholder="Header"></n-object>
    <n-object class="mt-2.5" :object="result" placeholder="Response"></n-object>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import NObject from "../../components/NObject.vue"

const url = ref("https://lilithvue.com/api/test")
const result = ref<Record<string, string>>({})
const header = ref<Record<string, string>>({})

const onRequest = () => {
  nz.request({
    url: url.value,
    method: "POST",
    data: { a: 1, b: "c" },
    success: res => {
      result.value = res.data
      header.value = res.header
    }, fail: err => {
      result.value = err
      header.value = {}
    }
  })
}
</script>
