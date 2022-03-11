<template>
  <div class="relative mt-5 mx-5 h-40">
    <video
      class="w-full h-full x"
      :autoplay="false"
      :muted="false"
      :src="data.videoURL"
      :poster="data.poster"
      loop
    ></video>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue"
const data = reactive({
  videoURL: "https://file.lilithvue.com/lilith-test-assets/v0200fg10000c8fdbqbc77ufgqhbio20.mp4",
  poster: ""
})
</script>
