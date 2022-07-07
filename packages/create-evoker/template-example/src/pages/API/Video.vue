<template>
  <n-cell-group class="m-2.5">
    <n-cell title="视频来源">
      <picker
        class="w-full"
        :range="sourceType.range"
        :value="sourceType.value"
        @change="onChangeSourceType"
        >{{ sourceType.range[sourceType.value] }}</picker
      >
    </n-cell>
    <n-cell title="摄像头">
      <picker class="w-full" :range="camera.range" :value="camera.value" @change="onChangeCamera">{{
        camera.range[camera.value]
      }}</picker>
    </n-cell>
    <n-cell title="拍摄长度">
      <picker
        class="w-full"
        :range="duration.range"
        :value="duration.value"
        @change="onChangeDuration"
        >{{ duration.range[duration.value] }}</picker
      >
    </n-cell>
  </n-cell-group>
  <button type="primary" @click="onChoose">选择</button>
  <div v-if="videoSrc.length" class="m-2.5 bg-white rounded-md shadow-sm p-2">
    <video class="w-full h-40" :autoplay="false" :muted="true" :src="videoSrc"></video>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"

const videoSrc = ref("")

const sourceType = reactive({
  range: ["拍照", "相册", "拍照或相册"],
  value: 2
})

const onChangeSourceType = e => {
  const value = e.detail.value
  sourceType.value = value
}

const camera = reactive({
  range: ["前置", "后置"],
  value: 1
})

const onChangeCamera = e => {
  const value = e.detail.value
  camera.value = value
}

const range = (start: number, end: number) => {
  let res = []
  for (let i = start; i <= end; i++) {
    res.push(i + "秒")
  }
  return res
}

const duration = reactive({
  range: range(1, 60),
  value: 59
})

const onChangeDuration = e => {
  const value = e.detail.value
  duration.value = value
}

const onChoose = async () => {
  const res = await ek.chooseVideo({
    maxDuration: parseInt(duration.range[duration.value]),
    camera: ["front", "back"][camera.value],
    sourceType: [["camera"], ["album"], ["camera", "album"]][sourceType.value],
    compressed: false
  })
  videoSrc.value = res.tempFilePath
}
</script>
