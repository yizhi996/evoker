// __UNSAFE__
// Reason: potentially setting innerHTML.
// This can come from explicit usage of v-html or innerHTML as a prop in render

import { warn } from "vue"

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
  if (key === "textContent") {
    if (prevChildren) {
      unmountChildren(prevChildren, parentComponent, parentSuspense)
    }
    el[key] = value == null ? "" : value
    return
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
