<template>
  <n-cell-group class="m-2.5">
    <n-cell title="用户信息">
      <icon v-if="auths['scope.userInfo'] === true" type="success"></icon>
    </n-cell>
    <n-cell title="地理位置">
      <icon v-if="auths['scope.userLocation'] === true" type="success"></icon>
    </n-cell>
    <n-cell title="录音功能">
      <icon v-if="auths['scope.record'] === true" type="success"></icon>
    </n-cell>
    <n-cell title="保存到相册">
      <icon v-if="auths['scope.writePhotosAlbum'] === true" type="success"></icon>
    </n-cell>
    <n-cell title="摄像头">
      <icon v-if="auths['scope.camera'] === true" type="success"></icon>
    </n-cell>
  </n-cell-group>
  <button type="primary" @click="getSetting">获取设置</button>
  <button @click="openSetting">打开设置</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const auths = ref({})

const getSetting = async () => {
  const res = await nz.getSetting({})
  auths.value = res.authSetting
}

const openSetting = async () => {
  const res = await nz.openSetting({})
  auths.value = res.authSetting
}
</script>