<template>
  <nz-slider>
    <div class="nz-slider__wrapper">
      <div class="nz-slider__input">
        <div
          class="nz-slider__input__bar"
          ref="barRef"
          :style="{ height: barHeight, 'background-color': inactiveColor }"
        >
          <div class="nz-slider__input__handle" ref="handleRef" :style="handleStyle"></div>
          <div class="nz-slider__input__thumb" :style="handleStyle"></div>
          <div
            class="nz-slider__input__track"
            :style="{ width: width, 'background-color': activeColor }"
          ></div>
        </div>
      </div>
    </div>
  </nz-slider>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick, getCurrentInstance } from "vue"
import { unitToPx } from "../utils/format"
import { useTouch } from "../use/useTouch"
import { safeRangeValue } from "../utils"

const emit = defineEmits(["update:modelValue", "change"])

const props = withDefaults(defineProps<{
  modelValue?: number,
  min?: number
  max?: number
  step?: number
  barHeight?: number | string
  buttonSize?: number | string
  activeColor?: string
  inactiveColor?: string
  disabled?: boolean
  name?: string
}>(), {
  modelValue: 0,
  min: 0,
  max: 100,
  setp: 1,
  barHeight: "2px",
  buttonSize: "24px",
  activeColor: "#1989fa",
  inactiveColor: "#e5e5e5",
  disabled: false
})

const instance = getCurrentInstance()!

const barRef = ref<HTMLElement>()
const handleRef = ref<HTMLElement>()
const touch = useTouch()

let isTouching = false

const width = computed(() => {
  return `${(props.modelValue / props.max) * 100}%`
})

const handleStyle = computed(() => {
  const value = unitToPx(props.buttonSize)
  const size = value + "px"
  const margin = -(value / 2) + "px"
  return {
    left: width.value,
    width: size,
    height: size,
    'margin-left': margin,
    'margin-top': margin
  }
})

let barRect = { left: 0, top: 0, width: 0 }

onMounted(() => {
  nextTick(() => {
    if (handleRef.value) {
      handleRef.value.addEventListener("touchstart", onTouchStart)
      handleRef.value.addEventListener("touchmove", onTouchMove)
      handleRef.value.addEventListener("touchend", onTouchEnd)
      handleRef.value.addEventListener("touchcancel", onTouchEnd)
    }
    if (barRef.value) {
      barResize()
      barRef.value.addEventListener("resize", barResize)
    }
  })
})

onUnmounted(() => {
  if (handleRef.value) {
    handleRef.value.removeEventListener("touchstart", onTouchStart)
    handleRef.value.removeEventListener("touchmove", onTouchMove)
    handleRef.value.removeEventListener("touchend", onTouchEnd)
    handleRef.value.removeEventListener("touchcancel", onTouchEnd)
  }
  if (barRef.value) {
    barRef.value.removeEventListener("resize", barResize)
  }
})

const onTouchStart = (event: TouchEvent) => {
  touch.start(event)
  isTouching = true
}

const onTouchMove = (event: TouchEvent) => {
  touch.move(event)
  event.preventDefault()
  isTouching = true

  const x = touch.deltaX.value + touch.startX.value - barRect.left

  const width = barRect.width
  let p = (x / width)
  p = safeRangeValue(p, 0, 1)
  const val = Math.round(props.max * p)
  instance.props.modelValue = val
  emit("update:modelValue", val)
}

const onTouchEnd = (event: TouchEvent) => {
  touch.reset()
  isTouching = false

}

const barResize = () => {
  barRect = barRef.value!.getBoundingClientRect()
}

const formData = () => {
  return props.modelValue
}

const resetFormData = () => {
  instance.props.modelValue = 0
  emit("update:modelValue", instance.props.modelValue)
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
      background-color: rgb(255, 255, 255);
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
}
</style>
