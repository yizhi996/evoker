import { clamp } from "@evoker/shared"
import { computed, defineComponent } from "vue"

export default defineComponent({
  props: {
    value: { type: Number, default: 0 }
  },
  setup(props) {
    const count = computed(() => {
      return clamp(Math.floor(props.value * 100 * 0.15), 0, 15)
    })
    return () => {
      const indicator = [...Array(count.value).keys()].map(i => (
        <i key={i} class="ev-video__screen-brightness__value__block"></i>
      ))
      return (
        <div class="ev-video__screen-brightness">
          <div>亮度</div>
          <div class="ev-video__screen-brightness__icon"></div>
          <div class="ev-video__screen-brightness__value">{indicator}</div>
        </div>
      )
    }
  }
})
