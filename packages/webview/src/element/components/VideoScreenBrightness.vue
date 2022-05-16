<template>
  <div class="nz-video__screen-brightness">
    <div>亮度</div>
    <div class="nz-video__screen-brightness__icon"></div>
    <div class="nz-video__screen-brightness__value">
      <i v-for="i of count" :key="i" class="nz-video__screen-brightness__value__block"></i>
    </div>
  </div>
</template>

<script setup lang="ts">
import { clamp } from "@nzoth/shared"
import { computed } from "vue"

const props = withDefaults(defineProps<{ value: number }>(), {
  value: 0
})

const count = computed(() => {
  return clamp(Math.floor(props.value * 100 * 0.15), 0, 15)
})
</script>

<style lang="less">
.nz-video__screen-brightness {
  position: absolute;
  background-color: white;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 140px;
  height: 140px;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);

  &__value {
    background-color: black;
    display: flex;
    width: 121px;
    height: 6px;

    &__block {
      background-color: white;
      width: 7px;
      height: 4px;
      margin-top: 1px;
      margin-left: 1px;
    }
  }

  &__icon {
    margin-top: 20px;
    margin-bottom: 20px;
    width: 56px;
    height: 56px;
    background-position: 50% 50%;
    background-repeat: no-repeat;
    background-size: cover;
    background-image: url("data:image/png;base64,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");
  }
}
</style>
