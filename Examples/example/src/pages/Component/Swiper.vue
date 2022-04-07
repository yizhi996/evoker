<template>
  <div class="mt-2.5 mx-2.5">
    <n-topic>Horizontal</n-topic>
    <swiper
      class="w-full h-40 text-white text-xl"
      :autoplay="autoplay"
      :circular="circular"
      indicator-dots
      indicator-active-color="white"
      :interval="interval"
      :duration="duration"
      :previous-margin="`${previousMargin}px`"
      :next-margin="`${nextMargin}px`"
    >
      <swiper-item
        v-for="color, i of items"
        :key="color"
        class="flex items-center justify-center"
        :class="color"
      >{{ i }}</swiper-item>
    </swiper>
    <n-topic>Vertical</n-topic>
    <swiper
      class="w-full h-40 text-white text-xl"
      :autoplay="autoplay"
      :circular="circular"
      indicator-dots
      indicator-active-color="white"
      vertical
      :interval="interval"
      :duration="duration"
      :previous-margin="`${previousMargin}px`"
      :next-margin="`${nextMargin}px`"
    >
      <swiper-item
        v-for="color, i of items"
        :key="color"
        class="flex items-center justify-center"
        :class="color"
      >{{ i }}</swiper-item>
    </swiper>

    <div class="mt-5 mx-2.5">
      <span>自动播放</span>
      <switch class="mx-2.5" v-model:checked="autoplay"></switch>
      <span>无限滚动</span>
      <switch class="ml-2.5" v-model:checked="circular"></switch>
      <div class="flex flex-col mt-1.5">
        <span>幻灯片切换时长(ms)</span>
        <slider
          :value="duration"
          show-value
          :min="500"
          :max="2000"
          :step="100"
          @change="onChangeDuration"
        ></slider>

        <span>自动播放间隔(ms)</span>
        <slider
          :value="interval"
          show-value
          :min="2000"
          :max="10000"
          :step="100"
          @change="onChangeInterval"
        ></slider>

        <span>前边距(px)</span>
        <slider
          :value="previousMargin"
          show-value
          :min="0"
          :max="50"
          @change="onChangePreviousMargin"
        ></slider>
        <span>后边距(px)</span>
        <slider :value="nextMargin" show-value :min="0" :max="50" @change="onChangeNextMargin"></slider>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const items = [
  "bg-blue-400",
  "bg-red-400",
  "bg-yellow-400",
  "bg-green-400"
]

const autoplay = ref(true)

const circular = ref(true)

const interval = ref(2000)

const onChangeInterval = (e) => {
  const value = e.detail.value
  interval.value = value
}

const duration = ref(500)

const onChangeDuration = (e) => {
  const value = e.detail.value
  duration.value = value
}

const previousMargin = ref(0)

const onChangePreviousMargin = (e) => {
  const value = e.detail.value
  previousMargin.value = value
}

const nextMargin = ref(0)

const onChangeNextMargin = (e) => {
  const value = e.detail.value
  nextMargin.value = value
}
</script>
