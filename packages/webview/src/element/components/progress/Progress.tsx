import { defineComponent, PropType, ref, watch } from "vue"
import { clamp } from "@evoker/shared"
import { Easing } from "@tweenjs/tween.js"
import { unitToPx } from "../../utils/format"
import { useJSAnimation } from "../../composables/useJSAnimation"

const props = {
  percent: { type: Number, default: 0 },
  showInfo: { type: Boolean, default: false },
  borderRadius: { type: [Number, String], default: 0 },
  fontSize: { type: [Number, String], default: 16 },
  strokeWidth: { type: [Number, String], default: 6 },
  activeColor: { type: String, default: "#1989fa" },
  backgroundColor: { type: String, default: "#e5e5e5" },
  active: { type: Boolean, default: false },
  activeMode: { type: String as PropType<"backwards" | "forwards">, default: "backwards" },
  duration: { Type: Number, default: 30 }
}

export default defineComponent({
  name: "ev-progress",
  props,
  emits: ["activeend"],
  setup(props, { emit }) {
    const currentPercent = ref<number>(0)

    const { startAnimation } = useJSAnimation<{ percent: number }>()

    const execAnimation = (percent: number) => {
      const begin = { percent: currentPercent.value }
      let diff = Math.abs(currentPercent.value - percent)
      if (props.activeMode === "backwards") {
        begin.percent = 0
        diff = percent
      }

      startAnimation({
        begin,
        end: { percent },
        duration: diff * props.duration,
        easing: Easing.Linear.None,
        onUpdate: ({ percent }) => {
          currentPercent.value = percent
        },
        onComplete: () => {
          emit("activeend", {})
        }
      })
    }

    watch(
      () => props.percent,
      percent => {
        if (props.active) {
          execAnimation(percent)
        } else {
          currentPercent.value = percent
        }
      },
      { immediate: true }
    )

    const renderTrack = () => {
      const borderRadius = `${unitToPx(props.borderRadius)}px`

      return (
        <div
          class="ev-progress__track"
          style={{
            height: `${unitToPx(props.strokeWidth)}px`,
            "background-color": props.backgroundColor,
            "border-radius": borderRadius
          }}
        >
          <div
            class="ev-progress__active"
            style={{
              width: `${clamp(currentPercent.value, 0, 100)}%`,
              "background-color": props.activeColor,
              "border-radius": borderRadius
            }}
          ></div>
        </div>
      )
    }

    const renderValut = () => {
      if (!props.showInfo) {
        return
      }
      return (
        <span class="ev-progress__value" style={{ "font-size": `${unitToPx(props.fontSize)}px` }}>
          {props.percent}%
        </span>
      )
    }

    return () => (
      <ev-progress>
        {renderTrack()}
        {renderValut()}
      </ev-progress>
    )
  }
})
