import {
  defineComponent,
  PropType,
  ref,
  watch,
  computed,
  onMounted,
  onUnmounted,
  nextTick
} from "vue"
import { ImageMode } from "../../utils/style"
import { addIntersectionObserve, removeIntersectionObserve } from "../../lazy/observer"
import { loadImage, ImageLoadResult } from "../../lazy/loader"
import { getImageModeStyleCssText } from "../../utils/style"

const props = {
  src: String,
  lazyLoad: { type: Boolean, default: false },
  mode: { type: String as PropType<ImageMode>, default: "scaleToFill" },
  webp: { type: Boolean, default: false }
}

export default defineComponent({
  name: "ev-image",
  props,
  emits: ["load", "error"],
  setup(props, { emit }) {
    const container = ref<HTMLElement>()
    const imageEl = ref<HTMLElement>()

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

    const style = computed(() => {
      return getImageModeStyleCssText(props.mode)
    })

    const getSrc = () => {
      if (props.webp) {
        return "webp" + props.src
      }
      return props.src
    }

    onMounted(() => {
      nextTick(() => {
        tryLoadImage()
      })
    })

    onUnmounted(() => {
      container.value && removeIntersectionObserve(container.value)
    })

    const updateSize = () => {
      const el = container.value
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
      const el = container.value
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
      const el = container.value
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
      const src = getSrc()
      if (!container.value || !src) {
        return
      }
      addIntersectionObserve(container.value, src, onLoad)
    }

    const immediateLoadImage = () => {
      const src = getSrc()
      if (!src) {
        return
      }
      loadImage(src).then(onLoad).catch(onError)
    }

    const onLoad = (result: ImageLoadResult) => {
      const src = `url("${result.src}")`
      imageEl.value && (imageEl.value.style.backgroundImage = src)
      imageSize.width = result.width
      imageSize.height = result.height
      updateSize()
      emit("load", { width: result.width, height: result.height })
    }

    const onError = (error: Error) => {
      emit("error", { errMsg: error })
    }

    return () => (
      <ev-image ref={container}>
        <div ref={imageEl} style={style.value}></div>
      </ev-image>
    )
  }
})
