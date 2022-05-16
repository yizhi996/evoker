<template>
  <button type="primary" @click="operateRecorder">{{ recording ? "停止录制" : "开始录制" }}</button>
  <button v-if="tempFilePath.length" type="primary" @click="operatePlayer">
    {{ playing ? "停止播放" : "开始播放" }}
  </button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const recording = ref(false)

const tempFilePath = ref("")

const recorderManager = nz.getRecorderManager()

recorderManager.onStart(() => {
  recording.value = true
})

recorderManager.onStop(res => {
  recording.value = false
  tempFilePath.value = res.tempFilePath
})

recorderManager.onError(res => {
  console.log(res)
})

const operateRecorder = () => {
  recording.value ? stopRecord() : startRecord()
}

const startRecord = () => {
  const options = {
    duration: 10000
  }
  recorderManager.start(options)
}

const stopRecord = () => {
  recorderManager.stop()
}

const audioContext = nz.createInnerAudioContext()

const playing = ref(false)

const operatePlayer = () => {
  playing.value ? stopPlay() : startPlay()
}

const startPlay = () => {
  audioContext.src = tempFilePath.value
  audioContext.play()
  playing.value = true
}

const stopPlay = () => {
  audioContext.stop()
  playing.value = false
}
</script>
