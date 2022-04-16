// __UNSAFE__
// Reason: potentially setting innerHTML.
// This can come from explicit usage of v-html or innerHTML as a prop in render

import { warn } from "vue"
import { includeBooleanAttr } from "@nzoth/shared"

// functions. The user is responsible for using them with only trusted content.
export function patchDOMProp(
  el: any,
  key: string,
  value: any,
  // the following args are passed only due to potential innerHTML/textContent
  // overriding existing VNodes, in which case the old tree must be properly
  // unmounted.
  prevChildren: any,
  parentComponent: any,
  parentSuspense: any,
  unmountChildren: any
) {
  if (key === "innerHTML" || key === "textContent") {
    if (prevChildren) {
      unmountChildren(prevChildren, parentComponent, parentSuspense)
    }
    el[key] = value == null ? "" : value
    return
  }

  if (key === "value" && el.tagName !== "PROGRESS") {
    // store value as _value as well since
    // non-string values will be stringified.
    el._value = value
    const newValue = value == null ? "" : value
    if (el.value !== newValue) {
      el.value = newValue
    }
    if (value == null) {
      el.removeAttribute(key)
    }
    return
  }

  if (value === "" || value == null) {
    const type = typeof el[key]
    if (type === "boolean") {
      // e.g. <select multiple> compiles to { multiple: '' }
      el[key] = includeBooleanAttr(value)
      return
    } else if (value == null && type === "string") {
      // e.g. <div :id="null">
      el[key] = ""
      el.removeAttribute(key)
      return
    } else if (type === "number") {
      // e.g. <img :width="null">
      // the value of some IDL attr must be greater than 0, e.g. input.size = 0 -> error
      try {
        el[key] = 0
      } catch {}
      el.removeAttribute(key)
      return
    }
  }

  if (key === "id") {
    el.id = value
    el.page.onPatchProp(el, key, value)
  } else {
    warn(
      `Failed setting prop "${key}" on <${el.tagName.toLowerCase()}>: ` +
        `value ${value} is invalid.`
    )
  }
}
