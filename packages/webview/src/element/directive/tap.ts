import { Directive } from "vue"
import { isFunction } from "@vue/shared"
import { addTap } from "../../dom/event"

export const vTap: Directive = {
  mounted(el, binding) {
    const modifiers = Object.keys(binding.modifiers)
    addTap(el, { modifiers }, (ev: TouchEvent) => {
      isFunction(binding.value) && binding.value()
    })
  }
}
