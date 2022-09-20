<template>
  <button type="primary" @click="long">长震动</button>
  <button type="primary" @click="short">短震动</button>
</template>

<script setup lang="ts">
const long = () => {
  ek.vibrateLong()
}

const short = () => {
  ek.vibrateShort({ type: "light" })
}
</script>
