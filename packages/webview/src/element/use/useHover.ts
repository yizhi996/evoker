import { ref, Ref, watch, computed, onMounted, onUnmounted } from "vue"

interface Props {
  hoverClass: string
  hoverStopPropagation: boolean
  hoverStartTime: number
  hoverStayTime: number
  disabled?: boolean
  loading?: boolean
}

export default function useHover(
  viewRef: Ref<HTMLElement | undefined>,
  props: Props
) {
  const hovering = ref(false)

  let hoverStartTimer: ReturnType<typeof setTimeout>
  let hoverStayTimer: ReturnType<typeof setTimeout>

  watch(
    () => props.hoverClass,
    () => {
      checkBindHover()
    }
  )

  onMounted(() => {
    checkBindHover()
  })

  onUnmounted(() => {
    unbindHover()
  })

  const finalHoverClass = computed(() => {
    if (hovering.value && props.hoverClass !== "none") {
      return props.hoverClass
    }
    return ""
  })

  const checkBindHover = () => {
    if (props.hoverClass === "none") {
      unbindHover()
    } else {
      bindHover()
    }
  }

  const bindHover = () => {
    if (viewRef.value) {
      viewRef.value.addEventListener("touchstart", hoverTouchStart)
      viewRef.value.addEventListener("canceltap", hoverCancel)
      viewRef.value.addEventListener("touchcancel", hoverCancel)
      viewRef.value.addEventListener("touchend", hoverTouchEnd)
    }
  }

  const unbindHover = () => {
    if (viewRef.value) {
      viewRef.value.removeEventListener("touchstart", hoverTouchStart)
      viewRef.value.removeEventListener("canceltap", hoverCancel)
      viewRef.value.removeEventListener("touchcancel", hoverCancel)
      viewRef.value.removeEventListener("touchend", hoverTouchEnd)
    }
  }

  const hoverTouchStart = (e: TouchEvent) => {
    props.hoverStopPropagation && e.stopPropagation()

    if (
      props.disabled ||
      props.loading ||
      e.touches.length > 1 ||
      hovering.value
    ) {
      return
    }

    hoverStartTimer = setTimeout(() => {
      hovering.value = true
    }, props.hoverStartTime)
  }

  const hoverTouchEnd = (e: Event) => {
    props.hoverStopPropagation && e.stopPropagation()

    clearTimeout(hoverStayTimer)
    hoverStayTimer = setTimeout(() => {
      hovering.value = false
    }, props.hoverStayTime)
  }

  const hoverCancel = (e: Event) => {
    props.hoverStopPropagation && e.stopPropagation()

    hovering.value = false
    clearTimeout(hoverStartTimer)
    clearTimeout(hoverStayTimer)
  }

  return {
    finalHoverClass,
    bindHover,
    unbindHover
  }
}
