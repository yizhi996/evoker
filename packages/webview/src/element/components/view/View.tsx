import { defineComponent, PropType, ref } from "vue"
import { useHover } from "../../composables/useHover"
import { useCSSAnimation, AnimationAction } from "../../composables/useCSSAnimation"

const props = {
  hoverClass: { type: String, default: "none" },
  hoverStopPropagation: { type: Boolean, default: false },
  hoverStartTime: { type: Number, default: 50 },
  hoverStayTime: { type: Number, default: 400 },
  animation: { type: Array as PropType<AnimationAction[]>, default: () => [] }
}

export default defineComponent({
  name: "ek-view",
  props,
  setup(props) {
    const el = ref<HTMLElement>()

    const { finalHoverClass } = useHover(el, props)

    useCSSAnimation(el, props)

    return () => <ek-view ref={el} class={finalHoverClass.value}></ek-view>
  }
})
