import { RendererOptions } from "vue"
import { NZothNode } from "../dom/node"
import { NZothElement } from "../dom/element"
import { isOn } from "@nzoth/shared"
import { patchStyle } from "./modules/style"
import { patchAttr } from "./modules/attrs"
import { patchDOMProp } from "./modules/props"
import { patchEvent } from "./modules/events"
import { patchClass } from "./modules/class"

type DOMRendererOptions = RendererOptions<NZothNode, NZothElement>

export const patchProp: DOMRendererOptions["patchProp"] = (
  el,
  key,
  prevValue,
  nextValue,
  isSVG = false,
  prevChildren,
  parentComponent,
  parentSuspense,
  unmountChildren
) => {
  if (key === "class") {
    patchClass(el, nextValue, isSVG)
  } else if (key === "style") {
    patchStyle(el, prevValue, nextValue)
  } else if (isOn(key)) {
    patchEvent(el, key, prevValue, nextValue, parentComponent)
  } else if (
    key[0] === "."
      ? ((key = key.slice(1)), true)
      : key[0] === "^"
      ? ((key = key.slice(1)), false)
      : shouldSetAsProp(el, key, nextValue, isSVG)
  ) {
    patchDOMProp(el, key, nextValue, prevChildren, parentComponent, parentSuspense, unmountChildren)
  } else {
    patchAttr(el, key, nextValue, isSVG, parentComponent)
  }
}

function shouldSetAsProp(el: NZothElement, key: string, value: unknown, isSVG: boolean) {
  if (isSVG) {
    // most keys must be set as attribute on svg elements to work
    // ...except innerHTML & textContent
    return key === "textContent"
  }

  return key in el
}
