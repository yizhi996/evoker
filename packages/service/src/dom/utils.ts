import { NZothComment } from "./comment"
import { NZothElement } from "./element"
import { NZothHTMLElement } from "./html"
import { NZothNode } from "./node"
import { NZothText } from "./text"
import { NZothSVGElement } from "./svg"

const enum Index {
  TAG = 1,
  CLASS = 2,
  ID = 3,
  ATTR = 4,
  EVENT = 5,
  TEXT = 6,
  STYLE = 7,
  COMMENT = 8,
  SVG = 9,
  HTML = 10
}

export function minifyNode(
  node: NZothNode | NZothElement | NZothHTMLElement | NZothComment | NZothText | NZothSVGElement
) {
  const miniNode: any[] = [node.nodeId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  // event target
  if (node.listeners) {
    miniNode[Index.EVENT] = node.listeners
  }

  // element
  if (node instanceof NZothElement) {
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

    if (node.innerHTML) {
      miniNode[Index.HTML] = node.innerHTML
    }

    if (node.textContent || node.textContent === "") {
      miniNode[Index.TEXT] = node.textContent
    }
  }

  if (node instanceof NZothHTMLElement) {
    miniNode[Index.STYLE] = node.style.styleObject
  } else if (node instanceof NZothComment) {
    miniNode[Index.COMMENT] = node.data
  } else if (node instanceof NZothSVGElement) {
    miniNode[Index.SVG] = true
  }

  return miniNode
}
