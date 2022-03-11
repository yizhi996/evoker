<template>
  <nz-progress>
    <div
      class="nz-progress__track"
      :style="{ height: strokeWidth, 'background-color': trackColor }"
    >
      <div class="nz-progress__active" :style="{ width: width, 'background-color': color }">
        <span
          v-if="showPivot"
          class="nz-progress__pivot"
          :style="{ left: width, transform: transform, color: textColor, 'background-color': pivotColor || color }"
        >{{ pivotText ?? width }}</span>
      </div>
    </div>
  </nz-progress>
</template>

<script setup lang="ts">
import { computed } from "vue"
import { safeRangeValue } from "../utils"
import { unitToPx } from "../utils/format"

const props = withDefaults(defineProps<{
  percentage: number | string
  strokeWidth?: number | string
  color?: string
  trackColor?: string
  pivotText?: string
  pivotColor?: string
  textColor?: string
  inactive?: boolean
  showPivot?: boolean
}>(), {
  percentage: 0,
  strokeWidth: "4px",
  color: "#1989fa",
  trackColor: "#e5e5e5",
  textColor: "white",
  inactive: false,
  showPivot: true
})


const width = computed(() => {
  const value = unitToPx(props.percentage)
  return `${safeRangeValue(value, 0, 100)}%`
})

const transform = computed(() => {
  const value = unitToPx(props.percentage)
  return `translate(-${+safeRangeValue(value, 0, 100)}%,-50%)`
})

</script>

<style lang="less">
nz-progress {
  display: inline-block;
  box-sizing: border-box;
  position: relative;
}

.nz-progress {
  &__track {
    position: relative;
    border-radius: 4px;
  }

  &__active {
    width: 0;
    height: 100%;
    border-radius: 4px;
  }

  &__pivot {
    position: absolute;
    top: 50%;
    text-align: center;
    padding: 0 5px;
    color: white;
    font-size: 10px;
    border-radius: 1em;
    min-width: 3.6em;
  }
}
</style>
