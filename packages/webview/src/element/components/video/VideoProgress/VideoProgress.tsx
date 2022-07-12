import { clamp } from "@evoker/shared"
import { defineComponent, ref } from "vue"
import { secondsToDuration } from "../../../utils/format"

export default defineComponent({
  name: "ek-video-progress",
  props: {
    currentTime: { type: Number, default: 0 },
    bufferTime: { type: Number, default: 0 },
    duration: { type: Number, default: 0 }
  },
  emits: ["slideStart", "sliding", "slideEnd"],
  setup(props, { emit }) {
    const progressRef = ref<HTMLElement>()

    const dutationPercent = (x: number) => {
      const p = (x / props.duration) * 100
      return `${clamp(p, 0, 100)}%`
    }

    return () => {
      return (
        <>
          <span class="ek-video__progress__time" style="margin-right: 8px">
            {secondsToDuration(props.currentTime)}
          </span>
          <div ref={progressRef} class="ek-video__progress">
            <div
              class="ek-video__progress__buffer"
              style={{ width: dutationPercent(props.bufferTime) }}
            ></div>
            <div
              class="ek-video__progress__played"
              style={{ width: dutationPercent(props.currentTime) }}
            ></div>
            <div
              class="ek-video__progress__handle"
              style={{ left: dutationPercent(props.currentTime) }}
              onTouchstart={ev => emit("slideStart", ev)}
              onTouchmove={ev => emit("sliding", ev, progressRef.value)}
              onTouchend={ev => emit("slideEnd", ev)}
              onTouchcancel={ev => emit("slideEnd", ev)}
            >
              <div class="ek-video__progress__ball"></div>
            </div>
          </div>
          <span class="ek-video__progress__time" style="margin-left: 8px">
            {secondsToDuration(props.duration)}
          </span>
        </>
      )
    }
  }
})
