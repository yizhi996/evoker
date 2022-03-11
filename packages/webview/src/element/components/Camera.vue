<template>
  <nz-camera>
    <div
      ref="containerRef"
      :id="tongcengKey"
      style="width:100%;height:100%;overflow:scroll;-webkit-overflow-scrolling:touch;"
    >
      <div style="width: 100%;" :style="height"></div>
    </div>
  </nz-camera>
</template>

<script setup lang="ts">
import { onMounted, watch } from "vue"
import { NZJSBridge } from "../../bridge"
import useNative from "../use/useNative"
import useCamera from "../listener/camera"

const emit = defineEmits(["initdone", "scancode", "error", "stop"])

const props = withDefaults(defineProps<{
  mode?: "normal" | "scanCode"
  resolution?: "low" | "medium" | "high"
  devicePosition?: "front" | "back"
  flash?: "auto" | "on" | "off" | "torch"
}>(), {
  mode: "normal",
  resolution: "medium",
  devicePosition: "back",
  flash: "auto"
})

const { tongcengKey, nativeId: cameraId, containerRef, height, insertContainer } = useNative()

const { onInit, onScanCode } = useCamera(cameraId)

onInit(data => {
  emit("initdone", data.maxZoom)
})

onScanCode(data => {
  emit("scancode", data.value)
})

watch(() => props.devicePosition, (newValue) => {
  update({ devicePosition: newValue })
})

watch(() => props.flash, (newValue) => {
  update({ flash: newValue })
})

watch(() => props.resolution, (newValue) => {
  update({ resolution: newValue })
})

onMounted(() => {
  setTimeout(() => {
    insert()
  })
})

const insert = () => {
  insertContainer((success) => {
    if (success) {
      NZJSBridge.invoke("insertCamera", {
        parentId: tongcengKey,
        cameraId,
        mode: props.mode,
        resolution: props.resolution,
        devicePosition: props.devicePosition
      })
    }
  })
}

const update = (params: Record<string, any>) => {
  NZJSBridge.invoke("updateCamera", params)
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
