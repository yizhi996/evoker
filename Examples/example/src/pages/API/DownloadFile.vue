<template>
  <div class="mx-2.5 mt-2.5">
    <img v-if="src" class="w-full" mode="widthFix" :src="src" />
    <n-topic v-else>下载远程图片</n-topic>
    <button class="mt-2.5" type="primary" @click="onDownload">download</button>
    <span>Progress: {{ progress }}</span>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const url =
  "https://file.lilithvue.com/lilith-test-assets/wallhaven-43y68y.jpg?imageMogr2/thumbnail/512x"

const src = ref("")

const progress = ref(0)

const onDownload = () => {
  const task = nz.downloadFile({
    url,
    filePath: nz.env.USER_DATA_PATH + "/test_img.jpg",
    success: res => {
      src.value = res.filePath
    },
    fail: err => {
      console.log(err)
    }
  })
  task?.onProgressUpdate(({ progress: p }) => {
    progress.value = p
  })
}
</script>
