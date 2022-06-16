<template>
  <map
    class="w-full h-80"
    :longitude="options.longitude"
    :latitude="options.latitude"
    :scale="options.scale"
    :show-location="options.showLocation"
    :show-compass="options.showCompass"
    :enable-3D="options.enable3D"
    :enable-zoom="options.enableZoom"
    :enable-scroll="options.enableScroll"
    :enable-rotate="options.enableRotate"
    :enable-satellite="options.enableSatellite"
    :enable-traffic="options.enableTraffic"
    @tappoi="onTap"
  ></map>

  <button @click="changeMapCenter">修改中心位置</button>

  <n-topic>修改缩放等级</n-topic>
  <slider :value="options.scale" @changing="onSliding" :min="3" :max="20" :step="0.1"></slider>

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
</template>

<script setup lang="ts">
import { reactive } from "vue"

let currentCenterIndex = 0

const center = [
  [121.928728, 30.902727],
  [121.499718, 31.239703]
]

const options = reactive({
  longitude: center[0][0],
  latitude: center[0][1],
  scale: 13,
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

const changeMapCenter = () => {
  currentCenterIndex += 1
  const index = currentCenterIndex % 2
  options.longitude = center[index][0]
  options.latitude = center[index][1]
}

const onSliding = ev => {
  const { value } = ev.detail as { value: number }
  options.scale = value
}

const onTap = ev => {
  console.log(ev.detail)
}
</script>
