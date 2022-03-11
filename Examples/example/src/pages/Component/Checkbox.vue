<template>
  <div class="mx-5">
    <checkbox class="mt-5" v-model="value1">复选框</checkbox>
    <checkbox class="mt-5" v-model="value2" disabled>复选框</checkbox>
    <checkbox class="mt-5" v-model="value3" disabled>复选框</checkbox>
    <checkbox class="mt-5" v-model="value4" color="red">自定义颜色</checkbox>
  </div>
  <checkbox-group class="mx-5 mt-5" v-model="value5">
    <checkbox class="mb-1.5" name="a">复选框 a</checkbox>
    <checkbox name="b">复选框 b</checkbox>
  </checkbox-group>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value1 = ref(true)
const value2 = ref(false)
const value3 = ref(true)
const value4 = ref(true)
const value5 = ref(["a"])

</script>
