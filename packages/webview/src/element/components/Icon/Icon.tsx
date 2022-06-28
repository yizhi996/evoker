import { computed, defineComponent, PropType } from "vue"
import { unitToPx } from "../../utils/format"

type IconType =
  | "success"
  | "success-no-circle"
  | "info"
  | "warn"
  | "waiting"
  | "cancel"
  | "download"
  | "search"
  | "clear"
  | "circle"
  | "info-circle"

const props = {
  type: { type: String as PropType<IconType> },
  size: { type: Number, default: 23 },
  color: { type: String, required: false }
}

export default defineComponent({
  name: "ev-icon",
  props,
  setup(props) {
    const iconSize = computed(() => {
      return unitToPx(props.size) + "px"
    })

    return () => (
      <ev-icon>
        <i
          class={"ev-icon--" + props.type}
          style={{ width: iconSize.value, height: iconSize.value, color: props.color }}
        ></i>
      </ev-icon>
    )
  }
})
