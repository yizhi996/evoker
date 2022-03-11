<template>
  <div
    v-for="(icons, i) of iconList"
    :key="i"
    class="flex flex-wrap justify-between mt-5 mx-2.5 bg-white rounded-sm shadow-sm"
  >
    <div
      v-for="icon of icons"
      :key="icon"
      class="relative flex items-center justify-center flex-1 w-1/3 min-w-1/3 max-w-1/3 square-image"
    >
      <div class="absolute flex flex-col items-center justify-center text-xs">
        <van-icon class="mb-3" :name="icon" size="50" />
        {{ icon }}
      </div>
    </div>
  </div>.
</template>

<script setup lang="ts">
import { reactive } from "vue"
import icons from "@vant/icons"
import { Icon as VanIcon } from "vant"
import "vant/es/icon/index.css"

const iconList = reactive([
  icons.basic,
  icons.outline,
  icons.filled
])
</script>

