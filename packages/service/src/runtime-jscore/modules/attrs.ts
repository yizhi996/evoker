import { ComponentInternalInstance } from "vue"
import { includeBooleanAttr, isSpecialBooleanAttr } from "@nzoth/shared"
import { NZothElement } from "../../dom/element"

export const xlinkNS = "http://www.w3.org/1999/xlink"

export function patchAttr(
  el: NZothElement,
  key: string,
  value: any,
  isSVG: boolean,
  instance?: ComponentInternalInstance | null
) {
  if (isSVG && key.startsWith("xlink:")) {
    if (value == null) {
      el.removeAttributeNS(xlinkNS, key.slice(6, key.length))
    } else {
      el.setAttributeNS(xlinkNS, key, value)
    }
  } else {
    // note we are only checking boolean attributes that don't have a
    // corresponding dom prop of the same name here.
    const isBoolean = isSpecialBooleanAttr(key)
    if (value == null || (isBoolean && !includeBooleanAttr(value))) {
      el.removeAttribute(key)
    } else {
      el.setAttribute(key, isBoolean ? "" : value)
    }
  }
}
