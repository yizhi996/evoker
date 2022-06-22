import { defineComponent, PropType, ref } from "vue"
import useHover from "../../use/useHover"
import { useCSSAnimation, AnimationAction } from "../../use/useCSSAnimation"

const props = {
  hoverClass: { type: String, default: "none" },
  hoverStopPropagation: { type: Boolean, default: false },
  hoverStartTime: { type: Number, default: 50 },
  hoverStayTime: { type: Number, default: 400 },
  animation: { type: Array as PropType<AnimationAction[]>, default: () => [] }
}

export default defineComponent({
  name: "nz-view",
  props,
  setup(props) {
    const el = ref<HTMLElement>()

    const { finalHoverClass } = useHover(el, props)

    useCSSAnimation(el, props)

    return () => <nz-view ref={el} class={finalHoverClass.value}></nz-view>
  }
})
