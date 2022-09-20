<template>
  <div
    class="sticky top-0 left-0 z-10 w-full"
    :style="{
      height: `${height}px`,
      'background-color': isShowDefaultNav ? 'white' : 'transparent'
    }"
  >
    <div class="absolute left-0 bottom-0 w-full h-11 flex items-center justify-center">
      <span v-if="isShowDefaultNav" class="text-[17px] font-semibold">{{ title }}</span>
    </div>
  </div>
  <div class="relative h-11">
    <div class="absolute left-4 bottom-0 text-[34px] font-bold">{{ title }}</div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue"

const props = defineProps<{ title: string; scrollTop: number }>()

const height = ek.getWindowInfo().statusBarHeight + 44

const isShowDefaultNav = computed(() => {
  return props.scrollTop > 20
})
</script>
