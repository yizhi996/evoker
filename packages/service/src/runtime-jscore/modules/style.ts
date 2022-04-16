import { camelize } from "vue"
import { isString, hyphenate, capitalize, isArray } from "@nzoth/shared"
import { NZothHTMLElement } from "../../dom/html"
import { NZothElement } from "../../dom/element"
import { NZothCSSStyleDeclaration } from "../../dom/style"

type Style = string | Record<string, string | string[]> | null

export function patchStyle(el: NZothElement, prev: Style, next: Style) {
  const style = (el as NZothHTMLElement).style
  const isCssString = isString(next)
  if (next && !isCssString) {
    for (const key in next) {
      setStyle(style, key, next[key])
    }
    if (prev && !isString(prev)) {
      for (const key in prev) {
        if (next[key] == null) {
          setStyle(style, key, "")
        }
      }
    }
  } else {
    const currentDisplay = style.display
    if (isCssString) {
      if (prev !== next) {
        style.cssText = next as string
      }
    } else if (prev) {
      el.removeAttribute("style")
      style.cleanAll()
    }
    // indicates that the `display` of the element is controlled by `v-show`,
    // so we always keep the current `display` value regardless of the `style`
    // value, thus handing over control to `v-show`.
    if ("_vod" in el) {
      style.display = currentDisplay
    }
  }

  el.page.onPatchStyle(el)
}

const importantRE = /\s*!important$/

function setStyle(
  style: NZothCSSStyleDeclaration,
  name: string,
  val: string | string[]
) {
  if (isArray(val)) {
    val.forEach(v => setStyle(style, name, v))
  } else {
    if (name.startsWith("--")) {
      // custom property definition
      style.setProperty(name, val)
    } else {
      const prefixed = autoPrefix(style, name)
      if (importantRE.test(val)) {
        // !important
        style.setProperty(
          hyphenate(prefixed),
          val.replace(importantRE, ""),
          "important"
        )
      } else {
        style.setProperty(prefixed, val)
      }
    }
  }
}

const prefixes = ["Webkit", "Moz", "ms"]
const prefixCache: Record<string, string> = {}

function autoPrefix(style: NZothCSSStyleDeclaration, rawName: string): string {
  const cached = prefixCache[rawName]
  if (cached) {
    return cached
  }
  let name = camelize(rawName)
  if (name !== "filter" && name in style) {
    return (prefixCache[rawName] = name)
  }
  name = capitalize(name)
  for (let i = 0; i < prefixes.length; i++) {
    const prefixed = prefixes[i] + name
    if (prefixed in style) {
      return (prefixCache[rawName] = prefixed)
    }
  }
  return rawName
}
