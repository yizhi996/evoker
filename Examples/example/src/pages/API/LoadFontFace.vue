<template>
  <div
    class="bg-white flex justify-center py-20 text-xl"
    :class="loaded ? 'font-loaded' : ''"
  >{{ loaded ? `${fontFamily} is loaded` : `Load ${fontFamily}` }}</div>
  <button type="primary" @click="onLoad">加载字体</button>
  <button @click="onClean">清除字体</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const fontFamily = "Bitstream Vera Serif Bold"

const loaded = ref(false)

const onLoad = async () => {
  await nz.loadFontFace({
    family: fontFamily,
    source: 'url("https://sungd.github.io/Pacifico.ttf")',
  })
  loaded.value = true
}

const onClean = () => {
  loaded.value = false
}

</script>

<style scoped>
.font-loaded {
  font-family: "Bitstream Vera Serif Bold";
}
</style>