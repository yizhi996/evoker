<template>
  <div class="mx-2.5 mt-2.5">
    <n-topic>isFocus: {{ focus }}</n-topic>
    <input
      class="w-full h-12 bg-white px-2.5"
      value="NZoth"
      placeholder="请输入"
      focus
      @focus="onFocus"
      @blur="onBlur"
    />
    <n-topic>Maxlength 10</n-topic>
    <input class="w-full h-12 bg-white px-2.5" placeholder="请输入" :maxlength="10" />
    <n-topic>Account: {{ account }}</n-topic>
    <input class="w-full h-12 bg-white px-2.5" v-model:value="account" placeholder="请输入" />
    <n-topic>Password: {{ password }}</n-topic>
    <input class="w-full h-12 bg-white px-2.5" v-model:value="password" password placeholder="请输入" />
    <n-topic>Number Type</n-topic>
    <input class="w-full h-12 bg-white px-2.5" type="number" placeholder="请输入" />
    <n-topic>Decimal Type</n-topic>
    <input class="w-full h-12 bg-white px-2.5" type="digit" placeholder="请输入" />
    <n-topic>Custom Style</n-topic>
    <input
      class="w-full h-12 bg-white px-2.5 text-red-400 text-xl text-center font-light"
      placeholder="请输入"
      placeholder-class="text-blue-400 text-xl font-light"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const focus = ref(false)
const account = ref("")
const password = ref("")

const onFocus = () => {
  focus.value = true
}

const onBlur = () => {
  focus.value = false
}

</script>
