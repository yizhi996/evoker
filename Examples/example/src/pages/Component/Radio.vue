<template>
  <radio-group v-model="value1">
    <radio name="1">单选框 1</radio>
    <radio name="2">单选框 2</radio>
  </radio-group>
</template>

<script setup lang="ts">
import { ref } from "vue"

const value1 = ref("1")

</script>
