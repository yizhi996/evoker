import { createRenderer, RendererOptions } from "vue"
import { extend } from "@vue/shared"
import { EvokerElement } from "../dom/element"
import { EvokerNode } from "../dom/node"
import { EvokerHTMLElement } from "../dom/html"
import { EvokerSVGElement } from "../dom/svg"
import { EvokerPage } from "../dom/page"
import { EvokerText } from "../dom/text"
import { EvokerComment } from "../dom/comment"
import { patchProp } from "./patchProp"

export const svgNS = "http://www.w3.org/2000/svg"

const nodeOps: Omit<RendererOptions<EvokerNode, EvokerElement>, "patchProp"> = {
  insert: (child, parent, anchor) => {
    parent.insertBefore(child, anchor || null)
  },

  remove: child => {
    const parent = child.parentNode
    if (parent) {
      parent.removeChild(child)
    }
  },

  /** @ts-ignore */
  createElement: (tag, isSVG, is, props, container): EvokerElement => {
    const page = container.page as EvokerPage
    const el = isSVG ? new EvokerSVGElement(svgNS, tag, page) : new EvokerHTMLElement(tag, page)
    return el
  },

  /** @ts-ignore */
  createText: (text, container) => {
    const page = container.page as EvokerPage
    return new EvokerText(text, page)
  },

  /** @ts-ignore */
  createComment: (text, container) => {
    const page = container.page as EvokerPage
    return new EvokerComment(text, page)
  },

  setText: (node, text) => {
    node.nodeValue = text
  },

  setElementText: (el, text) => {
    el.textContent = text
  },

  parentNode: node => node.parentNode as EvokerElement | null,

  nextSibling: node => node.nextSibling,

  setScopeId(el, id) {
    el.setAttribute(id, "")
  },

  cloneNode(el) {
    const cloned = el.cloneNode(true)
    if ("_value" in el) {
      ;(cloned as any)._value = (el as any)._value
    }
    return cloned
  },

  forcePatchProp(el: EvokerElement, key: string) {
    const keys = forcePatchProp[el.tagName]
    return keys && keys.includes(key)
  }
}

const forcePatchProp: Record<string, string[]> = {
  picker: ["range", "value"]
}

const rendererOptions = extend({ patchProp }, nodeOps)

export const renderer = createRenderer(rendererOptions)
