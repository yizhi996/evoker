import { defineComponent, ref, VNode, withDirectives } from "vue"
import { vTap } from "../../directive/tap"
import { isNZothElement } from "../../../dom/element"

const props = {
  for: { type: String, required: false }
}

export default defineComponent({
  name: "nz-label",
  props,
  setup(props) {
    const container = ref<HTMLElement>()

    const validTags = [
      "NZ-BUTTON",
      "NZ-INPUT",
      "NZ-TEXTAREA",
      "NZ-SWITCH",
      "NZ-RADIO",
      "NZ-CHECKBOX"
    ]

    const onTap = () => {
      if (props.for) {
        const el = document.getElementById(props.for)
        if (isNZothElement(el) && validTags.includes(el.tagName)) {
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
        if (isNZothElement(node) && validTags.includes(node.tagName)) {
          const { onTapLabel } = node.__instance.exposed!
          onTapLabel()
        } else {
          dfsTapLabelTarget(node as HTMLElement)
        }
      }
    }

    return () => {
      return withDirectives((<nz-label ref={container}></nz-label>) as VNode, [[vTap, onTap]])
    }
  }
})
