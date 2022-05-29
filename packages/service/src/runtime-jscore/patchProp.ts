import { RendererOptions } from "vue"
import { NZothNode } from "../dom/node"
import { NZothElement } from "../dom/element"
import { isOn, isFunction, isString } from "@nzoth/shared"
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

const nativeOnRE = /^on[a-z]/

function shouldSetAsProp(el: NZothElement, key: string, value: unknown, isSVG: boolean) {
  if (isSVG) {
    // most keys must be set as attribute on svg elements to work
    // ...except innerHTML & textContent
    if (key === "textContent") {
      return true
    }
    // or native onclick with function values
    if (key in el && nativeOnRE.test(key) && isFunction(value)) {
      return true
    }
    return false
  }

  // spellcheck and draggable are numerated attrs, however their
  // corresponding DOM properties are actually booleans - this leads to
  // setting it with a string "false" value leading it to be coerced to
  // `true`, so we need to always treat them as attributes.
  // Note that `contentEditable` doesn't have this problem: its DOM
  // property is also enumerated string values.
  if (key === "spellcheck" || key === "draggable") {
    return false
  }

  // #1787, #2840 form property on form elements is readonly and must be set as
  // attribute.
  if (key === "form") {
    return false
  }

  // #1526 <input list> must be set as attribute
  if (key === "list" && el.tagName === "INPUT") {
    return false
  }

  // #2766 <textarea type> must be set as attribute
  if (key === "type" && el.tagName === "TEXTAREA") {
    return false
  }

  // native onclick with string value, must be set as attribute
  if (nativeOnRE.test(key) && isString(value)) {
    return false
  }

  return key in el
}
