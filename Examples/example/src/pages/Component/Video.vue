<template>
  <div class="relative h-56">
    <video class="w-full h-full" enable-play-gesture :show-center-play-btn="true" :autoplay="false" :muted="true"
      show-mute-btn :src="data.videoURL" loop></video>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue"
const data = reactive({
  videoURL: "https://file.lilithvue.com/lilith-test-assets/v0200fg10000c8fdbqbc77ufgqhbio20.mp4",
  poster: ""
})
</script>
