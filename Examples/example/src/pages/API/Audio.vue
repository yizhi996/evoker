<template>
    <button type="primary" @click="onPlay">Play</button>
    <button @click="onPause">Pause</button>
</template>

<script setup lang="ts">

const ctx = nz.createInnerAudioContext()
ctx.src = "https://file.lilithvue.com/lilith-test-assets/3EM27_Beethoven9_Orch%2BCho.mp3"
ctx.volume = 0.3
ctx.loop = true

const onPlay = () => {
    ctx.play()
}

const onPause = () => {
    ctx.pause()
}
</script>