import { defineComponent, PropType, withDirectives, VNode } from "vue"
import { vTap } from "../../../directive/tap"
import { classNames } from "../../../utils"

export default defineComponent({
  props: {
    type: String as PropType<
      "play" | "pause" | "mute-on" | "mute-off" | "fullscreen" | "back" | "lock" | "unlock"
    >
  },
  emits: ["click"],
  setup(props, { emit }) {
    const onClick = () => {
      emit("click")
    }

    return () => {
      return withDirectives(
        (
          <div class={classNames("nz-video__button", `nz-video__icon--${props.type}`)}></div>
        ) as VNode,
        [[vTap, onClick, "", { stop: true }]]
      )
    }
  }
})
