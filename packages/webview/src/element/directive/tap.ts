import { Directive } from "vue"
import { isFunction } from "@vue/shared"
import { addTouchEvent } from "../../dom/event"

export const vTap: Directive = {
  mounted(el, binding) {
    const modifiers = Object.keys(binding.modifiers)
    el.__listenerOptions = { click: { modifiers } }
    addTouchEvent(el, undefined, ev => {
      isFunction(binding.value) && binding.value(ev)
    })
  }
}
