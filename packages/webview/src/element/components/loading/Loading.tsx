import { computed, defineComponent } from "vue"
import { unitToPx } from "../../utils/format"

const props = {
  size: { type: [Number, String], default: 20 },
  color: { type: String, default: "#fff" }
}

export default defineComponent({
  name: "ek-loading",
  props,
  setup(props) {
    const size = computed(() => {
      return `${unitToPx(props.size)}px`
    })

    return () => (
      <div class="ek-loading" style={{ width: size.value, height: size.value, color: props.color }}>
        <svg class="ek-loading__circle" viewBox="25 25 50 50">
          <circle cx="50" cy="50" r="20" fill="none" />
        </svg>
      </div>
    )
  }
})
