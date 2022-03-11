<template>
  <div class="mx-5">
    <button type="primary" @click="onClick">Primary</button>
    <button type="default" @click="onClick">Default</button>
    <button type="success" @click="onClick">Success</button>
    <button type="warning" @click="onClick">Waring</button>
    <button type="danger" @click="onClick">Danger</button>

    <button type="primary" plain @click="onClick">Plain</button>

    <button type="primary" color="orange" @click="onClick">Orange</button>
    <button type="primary" plain color="orange" @click="onClick">Orange Plain</button>

    <button type="primary" disabled @click="onClick">Disabled</button>
    <button type="default" disabled @click="onClick">Disabled</button>

    <button type="primary" loading @click="onClick">Loading</button>

    <button type="primary" size="large" @click="onClick">Large</button>
    <button type="primary" size="normal" @click="onClick">Noraml</button>
    <button type="primary" size="small" @click="onClick">Small</button>
    <button class="mx-3" type="primary" size="mini" @click="onClick">Mini</button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onBeforeUnmount, onUnmounted } from 'vue'

onMounted(() => {
  console.log("onMounted")
})

onBeforeUnmount(() => {
  console.log("onBeforeUnmount")
})

onUnmounted(() => {
  console.log("onUnmounted")
})

const onClick = () => {
  nz.showToast({
    title: "CLICK",
    icon: "none"
  })
}
</script>
