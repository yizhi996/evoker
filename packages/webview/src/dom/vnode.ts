import { VNode } from "vue"

export interface NZothEventListenerOptions {
  options?: EventListenerOptions
  modifiers?: string[]
}

export interface NZVNode {
  nodeId: number
  tagName: string
  className: string
  id: string
  attributes: Record<string, any>
  listeners: Record<string, NZothEventListenerOptions>
  textContent: string
  style: string
  data: string
  isSVG: boolean
  vnode?: VNode
  el?: any
  props?: Record<string, any>
}

export function restoreNode(data: any[]): NZVNode {
  const node: NZVNode = {
    nodeId: data[0],
    tagName: data[1],
    className: data[2],
    id: data[3],
    attributes: data[4],
    listeners: data[5],
    textContent: data[6],
    style: data[7],
    data: data[8],
    isSVG: data[9]
  }
  return node
}
