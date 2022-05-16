<template>
  <div class="w-full flex justify-center mt-2.5">
    <view class="w-20 h-20 bg-white flex items-center justify-center" :animation="animData"
      >TEST</view
    >
  </div>
  <button type="primary" @click="onStart">开启动画</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const anim = nz.createAnimation({ duration: 1000 })

const animData = ref(null)

const onStart = () => {
  anim.backgroundColor("#FF0000").opacity(1.0).rotate(45).scale(1.5).setp()
  anim.backgroundColor("#00FF00").opacity(0.5).setp()
  anim.backgroundColor("#FF0000").opacity(0.0).scale(1).setp()
  animData.value = anim.export()
}
</script>
