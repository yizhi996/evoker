<template>
  <div class="flex flex-col mx-3 space-y-3">
    <span>Local Image</span>
    <image class="w-20" mode="widthFix" src="../../assets/kind/daytime.png" />
    <span>WebP Internet Image</span>
    <img
      class="w-40"
      src="https://file.lilithvue.com/lilith-test-assets/rocket_top.webp"
      mode="widthFix"
      webp
    />
    <template v-for="src of images" :key="src">
      <span>Lazy Load Internet Image</span>
      <img class="w-full" mode="widthFix" lazy-load :src="src" />
    </template>
  </div>
</template>

<script setup lang="ts">
const files = [
  "wallhaven-43y68y.jpg",
  "wallhaven-4vvd13.jpg",
  "wallhaven-0wvdkx.jpg",
  "wallhaven-4dmozo.jpg",
  "wallhaven-45jmq8.jpg",
  "wallhaven-42wox6.jpg"
]

const images = files.map(
  f => `https://file.lilithvue.com/lilith-test-assets/${f}?imageMogr2/thumbnail/512x`
)
</script>
