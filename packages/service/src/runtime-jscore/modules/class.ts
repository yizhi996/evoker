import { NZothElement } from "../../dom/element"

export interface ElementWithTransition extends NZothElement {
  // _vtc = Vue Transition Classes.
  // Store the temporarily-added transition classes on the element
  // so that we can avoid overwriting them if the element's class is patched
  // during the transition.
  _vtc?: Set<string>
}

export function patchClass(el: NZothElement, value: string | null, isSVG: boolean) {
  const transitionClasses = (el as ElementWithTransition)._vtc
  if (transitionClasses) {
    value = (value ? [value, ...transitionClasses] : [...transitionClasses]).join(" ")
  }
  if (value == null) {
    el.className = ""
    el.removeAttribute("class")
  } else {
    el.className = value
    el.setAttribute("class", value)
  }
}
