import { defineComponent, ref, VNode, withDirectives } from "vue"
import { vTap } from "../../directive/tap"
import { isEvokerElement } from "../../../dom/element"

const props = {
  for: { type: String, required: false }
}

export default defineComponent({
  name: "ev-label",
  props,
  setup(props) {
    const container = ref<HTMLElement>()

    const validTags = [
      "EV-BUTTON",
      "EV-INPUT",
      "EV-TEXTAREA",
      "EV-SWITCH",
      "EV-RADIO",
      "EV-CHECKBOX"
    ]

    const onTap = () => {
      if (props.for) {
        const el = document.getElementById(props.for)
        if (isEvokerElement(el) && validTags.includes(el.tagName)) {
          const { onTapLabel } = el.__instance.exposed!
          onTapLabel()
        }
      } else {
        dfsTapLabelTarget(container.value!)
      }
    }

    const dfsTapLabelTarget = (el: HTMLElement) => {
      const childNodes = el.childNodes
      for (let i = 0; i < childNodes.length; i++) {
        const node = childNodes[i]
        if (isEvokerElement(node) && validTags.includes(node.tagName)) {
          const { onTapLabel } = node.__instance.exposed!
          onTapLabel()
        } else {
          dfsTapLabelTarget(node as HTMLElement)
        }
      }
    }

    return () => {
      return withDirectives((<ev-label ref={container}></ev-label>) as VNode, [[vTap, onTap]])
    }
  }
})
