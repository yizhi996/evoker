<template>
  <nz-slider>
    <div class="nz-slider__wrapper">
      <div class="nz-slider__input">
        <div
          class="nz-slider__input__bar"
          ref="barRef"
          :style="{ 'background-color': backgroundColor }"
        >
          <div class="nz-slider__input__handle" ref="handleRef" :style="handleStyle"></div>
          <div class="nz-slider__input__thumb" :style="handleStyle"></div>
          <div
            class="nz-slider__input__track"
            :style="{ width: width, 'background-color': activeColor }"
          ></div>
        </div>
      </div>
      <span v-if="showValue" class="nz-slider__value" :style="{ width: valueWidth }">{{
        value
      }}</span>
    </div>
  </nz-slider>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick, getCurrentInstance } from "vue"
import { unitToPx } from "../utils/format"
import useTouch from "../use/useTouch"
import { clamp } from "@nzoth/shared"

const emit = defineEmits(["update:value", "change", "changing"])

const props = withDefaults(
  defineProps<{
    value?: number
    min?: number
    max?: number
    step?: number
    activeColor?: string
    backgroundColor?: string
    blockSize?: number
    blockColor?: string
    showValue?: boolean
    disabled?: boolean
    name?: string
  }>(),
  {
    value: 0,
    min: 0,
    max: 100,
    step: 1,
    activeColor: "#1989fa",
    backgroundColor: "#e5e5e5",
    blockSize: 28,
    blockColor: "#ffffff",
    showValue: false,
    disabled: false
  }
)

const instance = getCurrentInstance()!

const barRef = ref<HTMLElement>()
const handleRef = ref<HTMLElement>()

const width = computed(() => {
  const value = clamp(props.value, props.min, props.max)
  return `${((value - props.min) / (props.max - props.min)) * 100}%`
})

const valueWidth = computed(() => {
  return `calc(${props.max.toString().length}ch + 1px)`
})

const handleStyle = computed(() => {
  const value = unitToPx(props.blockSize)
  const size = value + "px"
  const margin = -(value / 2) + "px"
  return {
    left: width.value,
    width: size,
    height: size,
    "margin-left": margin,
    "margin-top": margin,
    "background-color": props.blockColor
  }
})

let barRect = { left: 0, top: 0, width: 0 }

onMounted(() => {
  nextTick(() => {
    if (handleRef.value) {
      const { onTouchMove, onTouchEnd } = useTouch(handleRef.value)

      onTouchMove((ev, touch) => {
        ev.preventDefault()

        const x = touch.deltaX.value + touch.startX.value - barRect.left
        const percent = x / barRect.width
        let value = (props.max - props.min) * percent
        value = Math.round(value / props.step) * props.step + props.min
        value = clamp(value, props.min, props.max)
        instance.props.value = value
        emit("update:value", value)
        emit("changing", { value })
      })

      onTouchEnd(() => {
        emit("update:value", props.value)
        emit("change", { value: props.value })
      })
    }
    if (barRef.value) {
      barResize()
      barRef.value.addEventListener("resize", barResize)
    }
  })
})

onUnmounted(() => {
  if (barRef.value) {
    barRef.value.removeEventListener("resize", barResize)
  }
})

const barResize = () => {
  barRect = barRef.value!.getBoundingClientRect()
}

const formData = () => {
  return props.value
}

const resetFormData = () => {
  instance.props.value = 0
  emit("change", { value: instance.props.value })
}

defineExpose({
  formData,
  resetFormData
})
</script>

<style lang="less">
nz-slider {
  display: block;
  margin: 10px 18px;
  padding: 0;
}

.nz-slider {
  &__wrapper {
    display: flex;
    min-height: 16px;
    align-items: center;
  }

  &__input {
    flex: 1;
    padding: 8px 0;

    &__bar {
      z-index: 0;
      -webkit-tap-highlight-color: transparent;
      border-radius: 5px;
      height: 2px;
      position: relative;
      transition: background-color 0.3s ease;
    }

    &__thumb {
      z-index: 2;
      box-shadow: 0 0 4px rgba(0, 0, 0, 0.2);
    }

    &__handle {
      z-index: 3;
      background-color: transparent;
    }

    &__handle,
    &__thumb {
      border-radius: 50%;
      position: absolute;
      top: 50%;
    }

    &__track {
      border-radius: 6px;
      height: 100%;
      transition: background-color 0.3s ease;
    }
  }

  &__value {
    color: #888;
    font-size: 14px;
    margin-left: 1em;
    text-align: center;
  }
}
</style>
