<template>
  <div class="title">Hello world</div>
  <img class="icon" mode="widthFix" :src="icon" />
  <div class="count">count: {{ count }}</div>
  <button type="primary" @click="count++">Plus</button>
</template>

<script setup lang="ts">
import icon from '../assets/github.svg'
import { ref } from 'vue'

const count = ref(0)
</script>

<style scoped>
.title {
  font-size: 36px;
  font-weight: 700;
  margin-top: 20px;
}

.icon {
  width: 140px;
  margin-top: 20px;
}

.count {
  font-size: 20px;
  font-weight: 700;
  margin-top: 20px;
}
</style>
