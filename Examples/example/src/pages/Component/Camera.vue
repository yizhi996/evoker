<template>
  <div class="mt-5">
    <camera
      class="w-full h-80"
      mode="scanCode"
      resolution="high"
      device-position="back"
      flash="auto"
      @initdone="onInit"
      @scancode="onScanCode"
    ></camera>
    <button tpye @click="takePohto">拍照</button>
    <button tpye @click="startRecord">开始录像</button>
    <button tpye @click="stopRecord">停止录像</button>
    <button tpye @click="setZoom(2.0)">放大</button>
    <button tpye @click="setZoom(1.0)">缩小</button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"

const photoPath = ref("")
const videoInfo = reactive({
  videoPath: "",
  thumbPath: ""
})
const ctx = nz.createCameraContext()

const takePohto = async () => {
  const path = await ctx.takePhoto("high")
  photoPath.value = path
  nz.showToast({ title: path, icon: "none" })
}

const startRecord = async () => {
  await ctx.startRecord()
}

const stopRecord = async () => {
  const result = await ctx.stopRecord()
  videoInfo.thumbPath = result.tempThumbPath
  videoInfo.videoPath = result.tempVideoPath
}

const setZoom = (zoom: number) => {
  ctx.setZoom(zoom)
}

const onInit = (maxZoom: number) => {
  nz.showToast({ title: maxZoom.toString(), icon: "none" })
}

const onScanCode = (value: string) => {
  console.log(value)
}

</script>
