<template>
  <camera
    class="w-full h-80"
    mode="scanCode"
    resolution="high"
    device-position="back"
    flash="auto"
    @initdone="onInit"
    @scancode="onScanCode"
  ></camera>
  <span v-if="recordTime > 0">record: {{ recordTimeDisplay }}</span>
  <button @click="takePohto">拍照</button>
  <button @click="startRecord">开始录像</button>
  <button @click="stopRecord">停止录像</button>
  <button @click="setZoom(2.0)">放大到 2x</button>
  <button @click="setZoom(1.0)">缩小到 1x</button>
  <img class="w-full h-80" :src="photoPath" />
  <div class="relative h-80">
    <video
      class="absolute top-0 left-0 w-full h-full m"
      :autoplay="false"
      :muted="false"
      :src="videoInfo.videoPath"
      fullscreen
      loop
    ></video>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from "vue"

let timer: ReturnType<typeof setInterval>

const recordTime = ref(0)
const photoPath = ref("")
const videoInfo = reactive({
  videoPath: "",
  thumbPath: ""
})

const recordTimeDisplay = computed(() => {
  return recordTime.value > 0 ? (recordTime.value / 1000).toFixed(2) + " s" : ""
})

const ctx = nz.createCameraContext()

const takePohto = async () => {
  const result = await ctx.takePhoto({ quality: "high" })
  photoPath.value = result.tempImagePath
  nz.showToast({ title: result.tempImagePath, icon: "none" })
}

const startRecord = async () => {
  await ctx.startRecord()
  clearInterval(timer)
  timer = setInterval(() => {
    recordTime.value += 100
  }, 100)
}

const stopRecord = async () => {
  clearInterval(timer)
  recordTime.value = 0
  const result = await ctx.stopRecord()
  videoInfo.thumbPath = result.tempThumbPath
  videoInfo.videoPath = result.tempVideoPath
}

const setZoom = (zoom: number) => {
  ctx.setZoom({ zoom })
}

const onInit = (maxZoom: number) => {
  nz.showToast({ title: maxZoom.toString(), icon: "none" })
}

const onScanCode = (value: string) => {
  console.log(value)
}

</script>
