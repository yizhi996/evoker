import {
  ref,
  computed,
  onMounted,
  onUnmounted,
  nextTick,
  getCurrentInstance,
  defineComponent
} from "vue"
import { unitToPx } from "../../utils/format"
import { useTouch } from "../../composables/useTouch"
import { clamp } from "@evoker/shared"

const props = {
  value: { type: Number, default: 0 },
  min: { type: Number, default: 0 },
  max: { type: Number, default: 100 },
  step: { type: Number, default: 1 },
  activeColor: { type: String, default: "#1989fa" },
  backgroundColor: { type: String, default: "#e5e5e5" },
  blockSize: { type: Number, default: 28 },
  blockColor: { type: String, default: "#fff" },
  showValue: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  name: { type: String, required: false }
}

export default defineComponent({
  name: "ev-slider",
  props,
  emits: ["update:value", "change", "changing"],
  setup(props, { emit, expose }) {
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
            if (props.disabled) {
              return
            }
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
            if (props.disabled) {
              return
            }
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

    expose({
      formData: () => props.value,
      resetFormData: () => {
        instance.props.value = 0
        emit("change", { value: instance.props.value })
      }
    })

    const renderValue = () => {
      if (!props.showValue) {
        return
      }
      return (
        <span class="ev-slider__value" style={{ width: valueWidth.value }}>
          {props.value}
        </span>
      )
    }

    return () => (
      <ev-slider>
        <div class="ev-slider__wrapper">
          <div class="ev-slider__input">
            <div
              class="ev-slider__input__bar"
              ref={barRef}
              style={{ "background-color": props.backgroundColor }}
            >
              <div class="ev-slider__input__handle" ref={handleRef} style={handleStyle.value}></div>
              <div class="ev-slider__input__thumb" style={handleStyle.value}></div>
              <div
                class="ev-slider__input__track"
                style={{ width: width.value, "background-color": props.activeColor }}
              ></div>
            </div>
          </div>
          {renderValue()}
        </div>
      </ev-slider>
    )
  }
})
