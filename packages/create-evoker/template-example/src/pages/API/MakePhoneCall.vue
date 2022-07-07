<template>
  <div class="m-2.5 p-2.5 bg-white">
    <n-topic>请在下方输入电话号码</n-topic>
    <input
      class="m-2.5 w-full h-14 text-2xl"
      v-model:value="phoneNumber"
      placeholder="phone..."
      type="number"
      focus
    />
    <button type="primary" @click="onCall" :disabled="phoneNumber.length === 0">拨打</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const phoneNumber = ref("")

const onCall = () => {
  ek.makePhoneCall({ phoneNumber: phoneNumber.value })
}
</script>
