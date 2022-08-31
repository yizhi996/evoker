<template>
  <img class="w-full" mode="widthFix" :src="src" />
  <button type="primary" @click="chooseImage">+</button>
  <button :disabled="!tempFilePath" @click="saveFile">保存文件</button>
  <button :disabled="!savedFilePath" @click="removeFile">删除文件</button>
</template>

<script setup lang="ts">
import { ref, computed } from "vue"
import { usePage } from "evoker"

const fs = ek.getFileSystemManager()

const KEY = "savedFilePath"

const tempFilePath = ref("")

const savedFilePath = ref("")

const src = computed(() => {
  return savedFilePath.value || tempFilePath.value
})

const { onLoad } = usePage()

onLoad(async () => {
  const res = await ek.getStorage({ key: KEY })
  savedFilePath.value = res.data
})

const chooseImage = async () => {
  try {
    const res = await ek.chooseImage({ count: 1 })
    const path = res.tempFilePaths[0]
    tempFilePath.value = path
  } catch (e) {
    console.log(e)
  }
}

const saveFile = async () => {
  if (!tempFilePath.value) {
    return
  }
  try {
    savedFilePath.value = fs.saveFileSync(tempFilePath.value)
    tempFilePath.value = ""
    ek.setStorage({ key: KEY, data: savedFilePath.value })
    ek.showToast({ title: "保存成功, 退出应用后不会被删除", icon: "none" })
  } catch (e) {
    console.log(e)
  }
}

const removeFile = async () => {
  if (!savedFilePath.value) {
    return
  }

  try {
    await fs.removeSavedFile({ filePath: savedFilePath.value })
    ek.removeStorage({ key: KEY })
    savedFilePath.value = ""
  } catch (e) {
    console.log(e)
  }
}
</script>
