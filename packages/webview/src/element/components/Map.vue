<template>
  <nz-map>
    <div ref="tongcengRef" class="nz-native__tongceng" style="position: absolute" :id="tongcengKey">
      <div style="width: 100%" :style="height"></div>
    </div>
  </nz-map>
</template>

<script setup lang="ts">
import { watch, onMounted } from "vue"
import useNative from "../use/useNative"
import { useMap } from "../listener/map"
import { NZJSBridge } from "../../bridge"

const emit = defineEmits(["updated", "tap", "tappoi", "regionchange"])

const props = withDefaults(
  defineProps<{
    longitude: number
    latitude: number
    scale?: number
    minScale?: number
    maxScale?: number
    showLocation?: boolean
    showCompass?: boolean
    showScale?: boolean
    enableZoom?: boolean
    enableScroll?: boolean
    enableRotate?: boolean
    enableSatellite?: boolean
    enableTraffic?: boolean
    enableBuilding?: boolean
    enable3D?: boolean
  }>(),
  {
    scale: 16.0,
    minScale: 3.0,
    maxScale: 20.0,
    showLocation: false,
    showCompass: false,
    showScale: false,
    enableZoom: false,
    enableScroll: false,
    enableRotate: false,
    enableSatellite: false,
    enableTraffic: false,
    enableBuilding: false,
    enable3D: false
  }
)

const { tongcengKey, nativeId: mapId, tongcengRef, height, insertContainer } = useNative()

const { onUpdated, onTap, onTapPoi, onRegionChange } = useMap(mapId)

onUpdated(() => {
  emit("updated", {})
})

onTap(({ longitude, latitude }) => {
  emit("tap", { longitude, latitude })
})

onTapPoi(({ name, longitude, latitude }) => {
  emit("tappoi", { name, longitude, latitude })
})

onRegionChange(({ type, centerLocation }) => {
  emit("regionchange", { type, centerLocation })
})

watch(
  () => [props.longitude, props.latitude],
  ([longitude, latitude]) => {
    update({ longitude, latitude })
  }
)

watch(
  () => props.scale,
  newValue => {
    update({ scale: newValue })
  }
)

watch(
  () => props.minScale,
  newValue => {
    update({ minScale: newValue })
  }
)

watch(
  () => props.maxScale,
  newValue => {
    update({ maxScale: newValue })
  }
)

watch(
  () => props.showLocation,
  newValue => {
    update({ showLocation: newValue })
  }
)

watch(
  () => props.showCompass,
  newValue => {
    update({ showCompass: newValue })
  }
)

watch(
  () => props.showScale,
  newValue => {
    update({ showScale: newValue })
  }
)

watch(
  () => props.enableZoom,
  newValue => {
    update({ enableZoom: newValue })
  }
)

watch(
  () => props.enableScroll,
  newValue => {
    update({ enableScroll: newValue })
  }
)

watch(
  () => props.enableRotate,
  newValue => {
    update({ enableRotate: newValue })
  }
)

watch(
  () => props.enableSatellite,
  newValue => {
    update({ enableSatellite: newValue })
  }
)

watch(
  () => props.enableTraffic,
  newValue => {
    update({ enableTraffic: newValue })
  }
)

watch(
  () => props.enableBuilding,
  newValue => {
    update({ enableBuilding: newValue })
  }
)

watch(
  () => props.enable3D,
  newValue => {
    update({ enable3D: newValue })
  }
)

onMounted(() => {
  setTimeout(() => {
    insert()
  })
})

const insert = () => {
  insertContainer(success => {
    if (success) {
      NZJSBridge.invoke("insertMap", {
        parentId: tongcengKey,
        mapId,
        longitude: props.longitude,
        latitude: props.latitude,
        scale: props.scale,
        minScale: props.minScale,
        maxScale: props.maxScale,
        showLocation: props.showLocation,
        showCompass: props.showCompass,
        showScale: props.showScale,
        enableZoom: props.enableZoom,
        enableScroll: props.enableScroll,
        enableRotate: props.enableRotate,
        enableSatellite: props.enableSatellite,
        enableTraffic: props.enableTraffic,
        enableBuilding: props.enableBuilding,
        enable3D: props.enable3D
      })
    }
  })
}

const update = (params: Record<string, any>) => {
  NZJSBridge.invoke("updateMap", params)
}
</script>

<style>
nz-map {
  display: block;
  position: relative;
  width: 300px;
  height: 150px;
}
</style>
