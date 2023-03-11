import { ref } from "vue"
import { defineStore } from "pinia"

export const enum EnvVersion {
  RELEASE = "release",
  TRAIL = "trail",
  DEVELOP = "develop"
}

export interface App {
  url: string
  appId: string
  name?: string
  icon?: string
  desc?: string
  version: string
  envVersion: EnvVersion
}

export const useLocalStore = defineStore("local", () => {
  const apps = ref<App[]>([])

  const KEY_APPS = "k_apps"

  async function getLocalApps() {
    const res = ek.getStorageSync("k_setup")
    if (!res) {
      await ek.setStorage({
        key: KEY_APPS,
        data: [
          {
            url: "https://evokerdev.com",
            appId: "com.evokerdev.blank",
            name: "Hello world",
            version: "1.0.0",
            envVersion: "release"
          },
          {
            url: "https://evokerdev.com",
            appId: "com.evokerdev.example",
            name: "Example",
            desc: "Components and APIs example",
            icon: "https://file.evokerdev.com/app/com.evokerdev.example/assets/LOGO.png?imageMogr2/crop/256x256",
            version: "1.0.0",
            envVersion: "release"
          }
        ]
      })
      await ek.setStorage({ key: "k_setup", data: true })
    }

    const appsRes = await ek.getStorage({ key: KEY_APPS })
    if (appsRes.data) {
      apps.value = appsRes.data
    }
  }

  async function saveLocalApps() {
    ek.setStorage({ key: KEY_APPS, data: apps.value })
  }

  return {
    apps,
    getLocalApps,
    saveLocalApps
  }
})
