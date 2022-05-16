<template>
  <div class="m-2.5 text-sm text-gray-500">
    login 和 checkSession 接口需要根据自生业务在 native 端自行实现。具体请查看 NZEngineHooks 的
    openAPI。
  </div>
  <n-topic>Code: {{ code }}</n-topic>
  <button type="primary" @click="login">Login</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const code = ref("")

const login = async () => {
  const res = await nz.login({})
  code.value = res.code
}
</script>
