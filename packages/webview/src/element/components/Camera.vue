<template>
  <nz-camera>
    <div
      ref="containerRef"
      :id="tongcengKey"
      style="width: 100%; height: 100%; overflow: scroll; -webkit-overflow-scrolling: touch"
    >
      <div style="width: 100%" :style="height"></div>
    </div>
  </nz-camera>
</template>

<script setup lang="ts">
import { onMounted, watch } from "vue"
import { NZJSBridge, showModal } from "../../bridge"
import useNative from "../use/useNative"
import useCamera from "../listener/camera"
import { AuthorizationStatus } from "@nzoth/bridge"

const emit = defineEmits(["initdone", "scancode", "error", "stop"])

const props = withDefaults(
  defineProps<{
    mode?: "normal" | "scanCode"
    resolution?: "low" | "medium" | "high"
    devicePosition?: "front" | "back"
    flash?: "auto" | "on" | "off" | "torch"
  }>(),
  {
    mode: "normal",
    resolution: "medium",
    devicePosition: "back",
    flash: "auto"
  }
)

const { tongcengKey, nativeId: cameraId, containerRef, height, insertContainer } = useNative()

const { onInit, onScanCode, onError, authorize } = useCamera(cameraId)

onInit(data => {
  emit("initdone", { maxZoom: data.maxZoom })
})

onScanCode(data => {
  emit("scancode", { value: data.value })
})

onError(data => {
  showModal({
    title: "隐私权限",
    content: "请在 iPhone 的“设置-隐私”选项中，允许访问你的摄像头。",
    showCancel: false
  })
  emit("error", { errMsg: data.error })
})

watch(
  () => props.devicePosition,
  () => {
    update()
  }
)

watch(
  () => props.flash,
  () => {
    update()
  }
)

watch(
  () => props.resolution,
  () => {
    update()
  }
)

onMounted(() => {
  setTimeout(async () => {
    const status = await authorize()
    if (status === AuthorizationStatus.denied) {
      emit("error", { errMsg: "insertCamera: fail auth deny" })
    } else if (status === AuthorizationStatus.authorized) {
      insert()
    }
  })
})

const insert = () => {
  insertContainer(success => {
    if (success) {
      NZJSBridge.invoke("insertCamera", {
        parentId: tongcengKey,
        cameraId,
        mode: props.mode,
        flash: props.flash,
        resolution: props.resolution,
        devicePosition: props.devicePosition
      })
    }
  })
}

const update = () => {
  NZJSBridge.invoke("updateCamera", {
    cameraId,
    flash: props.flash,
    devicePosition: props.devicePosition
  })
}
</script>

<style>
nz-camera {
  display: block;
  position: relative;
  width: 100%;
  overflow: hidden;
}
</style>
