<template>
  <nz-canvas>
    <div ref="tongcengRef" class="nz-native__tongceng nz-canvas-tongceng" :id="tongcengKey">
      <div style="width: 100%" :style="height"></div>
    </div>
    <canvas></canvas>
  </nz-canvas>
</template>

<script setup lang="ts">
import { onMounted } from "vue"
import useNative from "../use/useNative"
import { NZJSBridge } from "../../bridge"

const props = withDefaults(
  defineProps<{
    type: "2d" | "webgl"
    canvasId?: string
  }>(),
  {
    type: "2d"
  }
)

const {
  tongcengKey,
  nativeId: canvasId,
  tongcengRef,
  height,
  insertContainer
} = useNative()

onMounted(() => {
  setTimeout(() => {
    insert()
  })
})

const insert = () => {
  insertContainer(success => {
    if (success) {
      NZJSBridge.invoke("insertCanvas2D", {
        parentId: tongcengKey,
        canvasId,
        type: props.type
      })
    }
  })
}

defineExpose({
  type: props.type,
  canvasId
})
</script>

<style>
nz-canvas {
  display: block;
  position: relative;
}

.nz-canvas-tongceng {
  position: absolute;
  left: 0;
  top: 0;
}
</style>
