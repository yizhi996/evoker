import { EvokerComment } from "./comment"
import { EvokerElement } from "./element"
import { EvokerHTMLElement } from "./html"
import { EvokerNode } from "./node"
import { EvokerText } from "./text"
import { EvokerSVGElement } from "./svg"

const enum Index {
  TAG = 1,
  CLASS = 2,
  ID = 3,
  ATTR = 4,
  EVENT = 5,
  TEXT = 6,
  STYLE = 7,
  COMMENT = 8,
  SVG = 9
}

export function minifyNode(
  node: EvokerNode | EvokerElement | EvokerHTMLElement | EvokerComment | EvokerText | EvokerSVGElement
) {
  const miniNode: any[] = [node.nodeId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  // event target
  if (node.listeners) {
    miniNode[Index.EVENT] = node.listeners
  }

  // element
  if (node instanceof EvokerElement) {
    miniNode[Index.TAG] = node.tagName

    if (node.className) {
      miniNode[Index.CLASS] = node.className
    }

    if (node.id) {
      miniNode[Index.ID] = node.id
    }

    if (node.attributes) {
      miniNode[Index.ATTR] = node.attributes
    }

    if (node.textContent != null) {
      miniNode[Index.TEXT] = node.textContent
    }
  }

  if (node instanceof EvokerHTMLElement) {
    miniNode[Index.STYLE] = node.style.styleObject
  } else if (node instanceof EvokerComment) {
    miniNode[Index.COMMENT] = node.data
  } else if (node instanceof EvokerSVGElement) {
    miniNode[Index.SVG] = true
  }

  return miniNode
}
