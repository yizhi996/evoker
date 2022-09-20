<template>
  <div class="bg-white text-center py-20 text-xl">
    {{ location.latitude }}, {{ location.longitude }}
  </div>
  <button type="primary" @click="getLocation">获取当前坐标</button>
</template>

<script setup lang="ts">
import { reactive, onMounted, onUnmounted } from "vue"

const location = reactive({
  latitude: 0,
  longitude: 0
})

onMounted(() => {
  ek.onLocationChange(onLocationChange)

  ek.startLocationUpdate({})
})

onUnmounted(() => {
  ek.stopLocationUpdate({})
  ek.offLocationChange(onLocationChange)
})

const getLocation = async () => {
  const res = await ek.getLocation({ type: "gcj02" })
  location.latitude = res.latitude.toFixed(3)
  location.longitude = res.longitude.toFixed(3)
}

const onLocationChange = ({ latitude, longitude }) => {
  location.latitude = latitude.toFixed(3)
  location.longitude = longitude.toFixed(3)
}
</script>
