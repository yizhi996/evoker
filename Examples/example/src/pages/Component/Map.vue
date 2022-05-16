<template>
  <div class="flex flex-col items-center justify-center space-y-2.5">
    <map
      class="w-full h-80"
      :longitude="100"
      :latitude="100"
      :show-location="options.showLocation"
      :show-compass="options.showCompass"
      :enable-3D="options.enable3D"
      :enable-zoom="options.enableZoom"
      :enable-scroll="options.enableScroll"
      :enable-rotate="options.enableRotate"
      :enable-satellite="options.enableSatellite"
      :enable-traffic="options.enableTraffic"
    ></map>

    <button @click="options.showLocation = !options.showLocation">
      {{ onoffText(options.showLocation) }}定位
    </button>
    <button @click="options.enable3D = !options.enable3D">
      {{ onoffText(options.enable3D) }} 3D 效果
    </button>
    <button>{{ onoffText(options.showLocation) }}俯视支持</button>
    <button @click="options.enableRotate = !options.enableRotate">
      {{ onoffText(options.enableRotate) }}旋转支持
    </button>
    <button @click="options.enableZoom = !options.enableZoom">
      {{ onoffText(options.enableZoom) }}缩放支持
    </button>
    <button @click="options.enableScroll = !options.enableScroll">
      {{ onoffText(options.enableScroll) }}拖动支持
    </button>
    <button @click="options.enableSatellite = !options.enableSatellite">
      {{ onoffText(options.enableSatellite) }}卫星图
    </button>
    <button @click="options.enableTraffic = !options.enableTraffic">
      {{ onoffText(options.enableTraffic) }}实时路况
    </button>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue"

const options = reactive({
  showLocation: false,
  enable3D: false,
  showCompass: false,
  enableZoom: true,
  enableScroll: true,
  enableRotate: true,
  enableSatellite: false,
  enableTraffic: false
})

const onoffText = (b: boolean) => {
  return b ? "关闭" : "开启"
}
</script>
