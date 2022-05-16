<template>
  <nz-image ref="containerRef">
    <div ref="imageRef" :style="style"></div>
  </nz-image>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed, watch, nextTick } from "vue"
import { addObserve, removeObserve, loadImage, ImageLoadResult } from "../lazy"
import type { ImageMode } from "../utils/style"
import { getImageModeStyleCssText } from "../utils/style"

const emit = defineEmits(["load", "error"])

const props = withDefaults(
  defineProps<{
    src: string
    lazyLoad?: boolean
    mode?: ImageMode
    webp?: boolean
  }>(),
  {
    lazyLoad: false,
    mode: "scaleToFill",
    webp: false
  }
)

const containerRef = ref<HTMLElement>()
const imageRef = ref<HTMLElement>()

let imageSize = { width: 0, height: 0 }

watch(
  () => props.mode,
  () => {
    updateSize()
  }
)

watch(
  () => props.src,
  () => {
    tryLoadImage()
  }
)

watch(
  () => props.webp,
  () => {
    tryLoadImage()
  }
)

const getSrc = () => {
  if (props.webp) {
    return "webp" + props.src
  }
  return props.src
}

const style = computed(() => {
  return getImageModeStyleCssText(props.mode)
})

onMounted(() => {
  nextTick(() => {
    tryLoadImage()
  })
})

onUnmounted(() => {
  containerRef.value && removeObserve(containerRef.value)
})

const updateSize = () => {
  const el = containerRef.value
  if (el) {
    if (props.mode === "widthFix") {
      const ratio = imageSize.width / imageSize.height
      el.style.height = getContainerWidth() / ratio + "px"
    } else if (props.mode === "heightFix") {
      const ratio = imageSize.height / imageSize.width
      el.style.width = getContainerHeight() / ratio + "px"
    } else {
      el.style.width = ""
      el.style.height = ""
    }
  }
}

const getContainerWidth = () => {
  const el = containerRef.value
  if (el) {
    const style = window.getComputedStyle(el)
    const borderLeftWidth = parseFloat(style.borderLeftWidth) || 0
    const borderRightWidth = parseFloat(style.borderRightWidth) || 0
    const paddingLeft = parseFloat(style.paddingLeft) || 0
    const paddingRight = parseFloat(style.paddingRight) || 0
    return el.offsetWidth - (borderLeftWidth + borderRightWidth - (paddingLeft + paddingRight))
  }
  return 0
}

const getContainerHeight = () => {
  const el = containerRef.value
  if (el) {
    const style = window.getComputedStyle(el)
    const borderTopWidth = parseFloat(style.borderTopWidth) || 0
    const borderBottomWidth = parseFloat(style.borderBottomWidth) || 0
    const paddingTop = parseFloat(style.paddingTop) || 0
    const paddingBottom = parseFloat(style.paddingBottom) || 0
    return el.offsetHeight - (borderTopWidth + borderBottomWidth - (paddingTop + paddingBottom))
  }
  return 0
}

const tryLoadImage = () => {
  props.lazyLoad ? lazyLoadImage() : immediateLoadImage()
}

const lazyLoadImage = () => {
  containerRef.value && addObserve(containerRef.value, getSrc(), onLazyLoad)
}

const immediateLoadImage = () => {
  loadImage(getSrc()).then(onLoad).catch(onError)
}

const onLazyLoad = (result: ImageLoadResult) => {
  onLoad(result)
}

const onLoad = (result: ImageLoadResult) => {
  const src = `url("${result.src}")`
  imageRef.value && (imageRef.value.style.backgroundImage = src)
  imageSize.width = result.width
  imageSize.height = result.height
  updateSize()
  emit("load", { width: result.width, height: result.height })
}

const onError = (error: Error) => {
  emit("error", { errMsg: error })
}
</script>

<style lang="less">
nz-image {
  display: inline-block;
  width: 320px;
  height: 240px;
  max-height: 100%;
  max-width: 100%;
  overflow: hidden;

  > div {
    height: 100%;
    width: 100%;
  }
}
</style>
