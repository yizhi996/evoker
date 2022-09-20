<template>
  <NavigationBar title="Launcher" :scroll-top="scrollTop"></NavigationBar>
  <div class="mt-3 mx-4 flex items-center justify-between">
    <span class="text-base text-gray-600">Apps</span>
    <icon
      class="rotate-45"
      type="clear"
      color="#007aff"
      size="28"
      @click="chooseImportAppMethod"
    ></icon>
  </div>
  <div class="mt-3 flex flex-col mx-4 bg-white rounded-md shadow-sm">
    <AppCell
      v-for="(app, i) of apps"
      :key="app.appId"
      :app="app"
      :index="i"
      :length="apps.length"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue"
import NavigationBar from "../components/NavigationBar.vue"
import { useLocalStore } from "../storage"
import { usePage } from "evoker"
import AppCell from "../components/AppCell.vue"
import { connectDevServer } from "../bridge"
import { parseURL } from "../utils"
import { subscribe } from "../apis"

const storage = useLocalStore()

storage.getLocalApps()

const apps = computed(() => {
  return storage.apps
})

const chooseImportAppMethod = async () => {
  const res = await ek.showActionSheet({
    alertText: "App import",
    itemList: ["URL"]
  })
  if (res.tapIndex === 0) {
    const res = await ek.showModal({
      title: "Please type app url",
      editable: true,
      placeholderText: "app url..."
    })
    if (res.confirm && res.content && res.content.length) {
      parseAppURL(res.content)
    }
  }
}

const parseAppURL = (urlstr: string) => {
  const url = parseURL(urlstr)
  if (url.protocol === "ws:") {
    connectDevServer({ url: urlstr })
  } else if (url.pathname.includes("cloud") && url.query.appId) {
    subscribe(url.origin, url.query.appId, url.query.envVersion as any)
  } else {
    ek.showToast({ title: "The url invalid", icon: "none" })
  }
}

const { onUnload, onPageScroll } = usePage()

onUnload(() => {})

const scrollTop = ref(0)

onPageScroll(res => {
  scrollTop.value = res.scrollTop
})
</script>
