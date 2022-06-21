import { Directive } from "vue"
import { isFunction } from "@vue/shared"
import { addClickEvent } from "../../dom/event"

export const vTap: Directive = {
  mounted(el, binding) {
    const modifiers = Object.keys(binding.modifiers)
    el.__listenerOptions = { click: { modifiers } }
    addClickEvent(el, ev => {
      isFunction(binding.value) && binding.value(ev)
    })
  }
}
