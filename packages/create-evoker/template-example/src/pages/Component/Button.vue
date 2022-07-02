<template>
  <div class="mx-5">
    <n-topic>Type</n-topic>
    <button type="primary" @click="onClick">Primary</button>
    <button type="default" @click="onClick">Default</button>
    <button type="success" @click="onClick">Success</button>
    <button type="warn" @click="onClick">Warn</button>
    <button type="danger" @click="onClick">Danger</button>

    <n-topic>Plain</n-topic>
    <button type="primary" plain @click="onClick">Primary</button>
    <button type="default" plain @click="onClick">Default</button>
    <button type="success" plain @click="onClick">Success</button>
    <button type="warn" plain @click="onClick">Warn</button>
    <button type="danger" plain @click="onClick">Danger</button>

    <n-topic>Custom Color</n-topic>
    <button type="primary" color="orange" @click="onClick">Orange</button>
    <button type="primary" plain color="orange" @click="onClick">Orange Plain</button>

    <n-topic>Disabled</n-topic>
    <button type="primary" disabled @click="onClick">Disabled</button>
    <button type="default" disabled @click="onClick">Disabled</button>

    <n-topic>Loading</n-topic>
    <button type="primary" loading @click="onClick">Loading</button>

    <n-topic>Size</n-topic>
    <button type="primary" size="large" @click="onClick">Large</button>
    <button type="primary" size="default" @click="onClick">Default</button>
    <button type="primary" size="small" @click="onClick">Small</button>
    <button class="mx-3" type="primary" size="mini" @click="onClick">Mini</button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onBeforeUnmount, onUnmounted } from "vue"

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
  ev.showToast({
    title: "CLICK",
    icon: "none"
  })
}
</script>
