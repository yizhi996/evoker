<template>
  <div class="relative width-full flex items-center h-[88px] px-3" @click="open">
    <div class="relative flex-shrink-0 w-14 h-14 rounded-md bg-gray-200">
      <img class="w-full h-full" :src="app.icon" />
      <span
        v-if="app.envVersion !== EnvVersion.RELEASE"
        class="absolute bottom-0 left-1/2 -translate-x-1/2 text-white bg-black bg-opacity-60 text-sm rounded-b-md w-full text-center"
        >{{ app.envVersion }}</span
      >
    </div>
    <div class="flex flex-col ml-4">
      <div class="text-lg">{{ app.name || app.appId }}</div>
      <div v-if="app.desc" class="text-xs text-gray-500">{{ app.desc }}</div>
      <div
        v-if="length !== 1 && index !== length - 1"
        class="h-[1px] bg-gray-100 absolute bottom-0"
        :style="{ width: `calc(100% - 56px - 24px)` }"
      ></div>
    </div>
    <icon
      class="absolute right-4"
      type="info-circle"
      color="purple"
      @click.stop="openAppConfig"
    ></icon>
  </div>
</template>

<script setup lang="ts">
import { App, EnvVersion } from "../storage"
import { connectDevServer, openApp, isRunning } from "../bridge"
import { update } from "../apis"
import { parseURL } from "../utils"

const props = defineProps<{ app: App; index: number; length: number }>()

const open = async () => {
  ek.showLoading({ title: "Loading", mask: true })
  const { url, appId, envVersion } = props.app
  try {
    const urlInfo = parseURL(url)
    const app = { appId, envVersion }
    if (urlInfo.protocol === "ws:") {
      openApp(app)
      connectDevServer({ url })
    } else {
      const { running } = await isRunning(app)
      if (!running) {
        await update(url, appId, envVersion)
        await openApp(app)
      } else {
        await openApp(app)
        await update(url, appId, envVersion)
      }
    }
    ek.hideLoading()
  } catch (e) {
    ek.showToast({ title: e.errMsg, icon: "none" })
  }
}

const openAppConfig = () => {
  ek.navigateTo({
    url: `./Config?appId=${props.app.appId}&envVersion=${props.app.envVersion}`
  })
}
</script>
