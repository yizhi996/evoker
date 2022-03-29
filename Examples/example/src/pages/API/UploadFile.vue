<template>
  <div class="mx-2.5 mt-2.5">
    <img v-if="src" class="w-full" mode="widthFix" :src="src" />
    <topic v-else>上传图片到服务器</topic>
    <button class="mt-2.5" type="primary" @click="onChooseImage">upload</button>
    <span>Progress: {{ progress }}</span>
  </div>
</template>

<script setup lang="ts">
import { ref, onUnmounted } from "vue"

const src = ref("")

const progress = ref(0)

let filename = ""

const onChooseImage = async () => {
  const result = await nz.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album'],
  })
  const { url, dir, auth, token } = await getAuthToken()

  deleteImage()

  const filePath = result.tempFilePaths[0]
  const key = dir + filePath.substr(filePath.lastIndexOf('/') + 1)
  filename = key
  const task = nz.uploadFile({
    url,
    name: "file",
    filePath: result.tempFilePaths[0],
    formData: {
      'key': key,
      'success_action_status': 200,
      'Signature': auth,
      'x-cos-security-token': token,
      'Content-Type': '',
    },
    success: res => {
      src.value = url + key
    }, fail: err => {
      console.log(err)
    }
  })
  task?.onProgressUpdate(({ progress: p }) => {
    progress.value = p
  })
}

const getAuthToken = () => {
  return new Promise((resolve, reject) => {
    nz.request({
      url: "https://lilithvue.com/api/cos/upload-token",
      method: "POST",
      success: res => {
        resolve(res.data.data)
      }, fail: err => {
        reject(err)
      }
    })
  })
}

const deleteImage = () => {
  if (filename) {
    nz.request({
      url: "https://lilithvue.com/api/cos/delete",
      method: "POST",
      data: { name: filename }
    })
  }
}

onUnmounted(() => {
  deleteImage()
})

</script>
