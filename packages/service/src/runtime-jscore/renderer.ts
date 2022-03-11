import { createRenderer, RendererOptions } from "vue"
import { extend } from "@vue/shared"
import { NZothElement } from "../dom/element"
import { NZothNode } from "../dom/node"
import { NZothHTMLElement } from "../dom/html"
import { NZothSVGElement } from "../dom/svg"
import { NZothPage } from "../dom/page"
import { NZothText } from "../dom/text"
import { NZothComment } from "../dom/comment"
import { patchProp } from "./patchProp"

export const svgNS = "http://www.w3.org/2000/svg"

const nodeOps: Omit<RendererOptions<NZothNode, NZothElement>, "patchProp"> = {
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
  createElement: (tag, isSVG, is, props, container): NZothElement => {
    const page = container.page as NZothPage
    const el = isSVG
      ? new NZothSVGElement(svgNS, tag, page)
      : new NZothHTMLElement(tag, page)
    return el
  },

  /** @ts-ignore */
  createText: (text, container) => {
    const page = container.page as NZothPage
    return new NZothText(text, page)
  },

  /** @ts-ignore */
  createComment: (text, container) => {
    const page = container.page as NZothPage
    return new NZothComment(text, page)
  },

  setText: (node, text) => {
    node.nodeValue = text
  },

  setElementText: (el, text) => {
    el.textContent = text
  },

  parentNode: node => node.parentNode as NZothElement | null,

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

  forcePatchProp(el: NZothElement, key: string) {
    const keys = forcePatchProp[el.tagName]
    return keys && keys.includes(key)
  }
}

const forcePatchProp: Record<string, string[]> = {
  picker: ["columns"]
}

const rendererOptions = extend({ patchProp }, nodeOps)

export const renderer = createRenderer(rendererOptions)
