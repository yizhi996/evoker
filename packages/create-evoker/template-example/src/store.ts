import { ref } from "vue"
import { defineStore } from "pinia"
import { ramdomString } from "./utils"

export const useLocalStore = defineStore("local", () => {
  const deviceId = ref("")

  const KEY = "k_device_id"

  async function getDeviceId() {
    if (deviceId.value === "") {
      const init = () => {
        deviceId.value = ramdomString(12)
        ek.setStorage({ key: KEY, data: deviceId.value })
      }
      try {
        const res = await ek.getStorage({ key: KEY })
        if (res.data) {
          deviceId.value = res.data
        } else {
          init()
        }
      } catch {
        init()
      }
    }
    return deviceId.value
  }

  return {
    getDeviceId
  }
})
