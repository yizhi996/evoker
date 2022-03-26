<template>
  <div class="mx-2.5 mt-2.5">
    <topic>isFocus: {{ focus }}</topic>
    <input
      class="w-full h-12 bg-white px-2.5"
      value="NZoth"
      placeholder="请输入"
      focus
      @focus="onFocus"
      @blur="onBlur"
    />
    <topic>Maxlength 10</topic>
    <input class="w-full h-12 bg-white px-2.5" placeholder="请输入" :maxlength="10" />
    <topic>Account: {{ account }}</topic>
    <input class="w-full h-12 bg-white px-2.5" v-model:value="account" placeholder="请输入" />
    <topic>Password: {{ password }}</topic>
    <input class="w-full h-12 bg-white px-2.5" v-model:value="password" password placeholder="请输入" />
    <topic>Number Type</topic>
    <input class="w-full h-12 bg-white px-2.5" type="number" placeholder="请输入" />
    <topic>Decimal Type</topic>
    <input class="w-full h-12 bg-white px-2.5" type="digit" placeholder="请输入" />
    <topic>Custom Style</topic>
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
