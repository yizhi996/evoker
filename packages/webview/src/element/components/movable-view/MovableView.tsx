import { ref, reactive, watch, onMounted, getCurrentInstance, PropType, defineComponent } from "vue"
import { useTouch } from "../../composables/useTouch"
import { useParent } from "../../composables/useRelation"
import { MOVABLE_KEY } from "../movable-area/constant"
import { unitToPx } from "../../utils/format"
import { Easing } from "@tweenjs/tween.js"
import { useJSAnimation } from "../../composables/useJSAnimation"

const props = {
  direction: {
    type: String as PropType<"all" | "vertical" | "horizontal" | "none">,
    default: "none"
  },
  inertia: { type: Boolean, required: false },
  outOfBounds: { type: Boolean, default: false },
  x: { type: Number, required: false },
  y: { type: Number, required: false },
  damping: { type: Number, default: 20 },
  friction: { type: Number, default: 2 },
  disabled: { type: Boolean, default: false },
  scale: { type: Boolean, default: false },
  scaleMin: { type: Number, default: 0.5 },
  scaleMax: { type: Number, default: 10 },
  scaleValue: { type: Number, default: 1 },
  animation: { type: Boolean, default: true }
}

export default defineComponent({
  name: "nz-movable-view",
  props,
  emits: ["update:x", "update:y", "change", "scale"],
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const container = ref<HTMLElement>()
    const size = reactive({ width: 0, height: 0 })
    const areaRect = reactive({
      x: 0,
      y: 0,
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      width: 0,
      height: 0
    })
    const transform = ref("translateX(0px) translateY(0px) translateZ(0px) scale(1)")

    const offset = { x: 0, y: 0 }
    const startOffset = { x: 0, y: 0 }
    let isTouching = false
    let isMounted = false

    watch(
      () => [props.x, props.y],
      () => {
        if (isTouching) {
          return
        }
        const x = unitToPx(props.x || 0)
        const y = unitToPx(props.y || 0)
        if (x !== offset.x || y !== offset.y) {
          if (isMounted) {
            onMoveWithPropsChange(x, y, true)
          }
        }
      }
    )

    onMounted(() => {
      addTouchEvent()

      setTimeout(() => {
        const parent = useParent(instance, MOVABLE_KEY)
        if (!parent) {
          console.warn("MovableView 必须添加在 MovableArea 内")
        }
      })
    })

    const addTouchEvent = () => {
      const { onTouchStart, onTouchMove, onTouchEnd } = useTouch(container.value!)
      onTouchStart(() => {
        isTouching = true
        startOffset.x = offset.x
        startOffset.y = offset.y
      })

      onTouchMove((ev, touch) => {
        ev.preventDefault()

        isTouching = true

        let x = 0
        if (props.direction !== "vertical") {
          x = startOffset.x + touch.deltaX.value - areaRect.left + areaRect.left
          const maxX = areaRect.width - size.width
          if (x < 0) {
            x = 0
          } else if (x > maxX) {
            x = maxX
          }
        }

        let y = 0
        if (props.direction !== "horizontal") {
          y = startOffset.y + touch.deltaY.value - areaRect.top + areaRect.top
          const maxY = areaRect.height - size.height
          if (y < 0) {
            y = 0
          } else if (y > maxY) {
            y = maxY
          }
        }

        offset.x = x
        offset.y = y

        transform.value = `translateX(${x}px) translateY(${y}px) translateZ(0px) scale(${1})`

        emitChange(x, y)
      })

      onTouchEnd(() => {
        emitChange(offset.x, offset.y)
        isTouching = false
      })
    }

    const onMoveWithPropsChange = (x: number, y: number, animation: boolean) => {
      let sfaeX = x
      if (props.direction !== "vertical") {
        const maxX = areaRect.width - size.width
        if (sfaeX < 0) {
          sfaeX = 0
        } else if (sfaeX > maxX) {
          sfaeX = maxX
        }
      }

      let safeY = y
      if (props.direction !== "horizontal") {
        const maxY = areaRect.height - size.height
        if (safeY < 0) {
          safeY = 0
        } else if (safeY > maxY) {
          safeY = maxY
        }
      }

      onMove(sfaeX, safeY, animation)
    }

    const { startAnimation, stopAnimation } = useJSAnimation<{
      x: number
      y: number
      scale: number
    }>()

    const onMove = (x: number, y: number, animation: boolean) => {
      const scale = 1

      stopAnimation()

      if (animation && props.animation) {
        startAnimation({
          begin: { x: offset.x, y: offset.y, scale },
          end: { x, y, scale },
          duration: 1000,
          easing: Easing.Quartic.Out,
          onUpdate: ({ x, y, scale }) => {
            offset.x = x
            offset.y = y
            transform.value = `translateX(${x}px) translateY(${y}px) translateZ(0px) scale(${scale})`
          },
          onComplete: () => {
            emitChange(x, y)
          }
        })
      } else {
        transform.value = `translateX(${x}px) translateY(${y}px) translateZ(0px) scale(${scale})`
        offset.x = x
        offset.y = y
        emitChange(x, y)
      }
    }

    const emitChange = (x: number, y: number) => {
      if (props.x !== x) {
        instance.props.x = x
        emit("update:x", x)
      }

      if (props.y !== y) {
        instance.props.y = y
        emit("update:y", y)
      }

      emit("change", { x, y })
    }

    expose({
      setAreaRect: (rect: DOMRect) => {
        areaRect.x = rect.x
        areaRect.y = rect.y
        areaRect.left = rect.left
        areaRect.right = rect.right
        areaRect.top = rect.top
        areaRect.bottom = rect.bottom
        areaRect.width = rect.width
        areaRect.height = rect.height

        const viewRect = container.value!.getBoundingClientRect()
        size.width = viewRect.width
        size.height = viewRect.height

        const x = unitToPx(props.x || 0)
        const y = unitToPx(props.y || 0)
        onMoveWithPropsChange(x, y, false)

        isMounted = true
      }
    })

    return () => (
      <nz-movable-view
        ref={container}
        style={{
          "transform-origin": "center",
          "will-change": isTouching ? "transform" : "auto",
          transform: transform.value
        }}
      ></nz-movable-view>
    )
  }
})
