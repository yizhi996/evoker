<template>
  <nz-progress>
    <div
      class="nz-progress__track"
      :style="{ height: `${unitToPx(strokeWidth)}px`, 'background-color': backgroundColor, 'border-radius': `${unitToPx(borderRadius)}px` }"
    >
      <div
        class="nz-progress__active"
        :style="{ width: `${safeRangeValue(currentPercent, 0, 100)}%`, 'background-color': activeColor, 'border-radius': `${unitToPx(borderRadius)}px` }"
      ></div>
    </div>
    <span
      v-if="showInfo"
      class="nz-progress__value"
      :style="{ 'font-size': `${unitToPx(fontSize)}px` }"
    >{{ percent }}%</span>
  </nz-progress>
</template>

<script setup lang="ts">
import { ref, watch } from "vue"
import { safeRangeValue } from "../utils"
import { unitToPx } from "../utils/format"
import { Tween, Easing, update } from "@tweenjs/tween.js"

const emit = defineEmits(["activeend"])

const props = withDefaults(defineProps<{
  percent?: number
  showInfo?: boolean
  borderRadius?: number | string
  fontSize?: number | string
  strokeWidth?: number | string
  activeColor?: string
  backgroundColor?: string
  active?: boolean
  activeMode?: "backwards" | "forwards"
  duration?: number
}>(), {
  percent: 0,
  showInfo: false,
  borderRadius: 0,
  fontSize: 16,
  strokeWidth: 6,
  activeColor: "#1989fa",
  backgroundColor: "#e5e5e5",
  active: false,
  activeMode: "backwards",
  duration: 30
})

const currentPercent = ref<number>(0)

let currentAnimation = 0
let currentTween: Tween<{ percent: number }>

const animate = () => {
  currentAnimation = requestAnimationFrame(animate)
  update()
}

const execAnimation = (percent: number) => {
  cancelAnimationFrame(currentAnimation)
  currentTween && currentTween.stop()

  currentAnimation = requestAnimationFrame(animate)

  const temp = { percent: currentPercent.value }
  let diff = Math.abs(currentPercent.value - percent)
  if (props.activeMode === "backwards") {
    temp.percent = 0
    diff = percent
  }

  currentTween = new Tween(temp)
    .to({ percent }, diff * props.duration)
    .easing(Easing.Linear.None)
    .onUpdate(({ percent }) => {
      currentPercent.value = percent
    })
    .onComplete(() => {
      cancelAnimationFrame(currentAnimation)
      emit("activeend", {})
    })
    .start()
}

watch(() => props.percent, (percent) => {
  if (props.active) {
    execAnimation(percent)
  } else {
    currentPercent.value = percent
  }
}, { immediate: true })

</script>

<style lang="less">
nz-progress {
  display: flex;
  align-items: center;
  width: 100%;
}

.nz-progress {
  &__track {
    flex: 1;
  }

  &__active {
    width: 0;
    height: 100%;
  }

  &__value {
    font-size: 16px;
    margin-bottom: 0;
    margin-left: 15px;
    margin-top: 0;
    min-width: 2em;
  }
}
</style>
