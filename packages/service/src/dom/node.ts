import { NZothPage } from "./page"
import { NZothEventTarget } from "./eventTarget"
import { NZothHTMLElement } from "./html"
import { NZothCSSStyleDeclaration } from "./style"
import { extend } from "@vue/shared"

export class NZothNode extends NZothEventTarget {
  page: NZothPage

  nodeId: number = 0

  parentNode?: NZothNode
  anchorNode?: NZothNode | null

  childNodes: NZothNode[]

  isMounted = false

  private _textContent: string | null = null
  private _nodeValue: string | null = null

  constructor(page: NZothPage) {
    super()
    this.page = page
    this.page.appendChildNode(this)
    this.childNodes = []
  }

  insertBefore(child: NZothNode, anchor?: NZothNode | null): NZothNode {
    child.parentNode = this
    child.anchorNode = anchor
    if (anchor) {
      let i = this.childNodes.indexOf(anchor)
      if (i > -1) {
        this.childNodes.splice(i, 0, child)
      }
    } else {
      this.childNodes.push(child)
    }
    this.page.onInsertBefore(this, child, anchor)
    this.isMounted = true
    child.isMounted = true
    anchor && (anchor.isMounted = true)
    return child
  }

  removeChild(child: NZothNode): NZothNode {
    child.parentNode = undefined
    const i = this.childNodes.indexOf(child)
    if (i > -1) {
      this.childNodes.splice(i, 1)
    }
    this.page.onRemove(this, child)
    child.isMounted = false
    return child
  }

  cloneNode(deep?: boolean): NZothNode {
    const clone = extend(Object.create(Object.getPrototypeOf(this)), this) as NZothHTMLElement
    clone.isMounted = false

    const { attributes, style } = clone

    if (attributes) {
      clone.attributes = extend(Object.create(null), attributes)
    }

    if (style) {
      clone.style = new NZothCSSStyleDeclaration(clone)
      clone.style._style = extend(Object.create(null), style._style)
    }

    if (deep) {
      clone.childNodes = clone.childNodes.map(childNode => childNode.cloneNode(true))
    }

    return clone
  }

  get firstChild(): NZothNode | null {
    return this.childNodes[0]
  }

  get lastChild(): NZothNode | null {
    return this.childNodes[this.childNodes.length - 1]
  }

  get nextSibling(): NZothNode | null {
    if (this.parentNode) {
      const { childNodes } = this.parentNode
      return childNodes[childNodes.indexOf(this) + 1]
    }
    return null
  }

  get previousSibling(): NZothNode | null {
    if (this.parentNode) {
      const { childNodes } = this.parentNode
      return childNodes[childNodes.indexOf(this) - 1]
    }
    return null
  }

  get textContent(): string | null {
    return this._textContent
  }

  set textContent(newValue: string | null) {
    this._textContent = newValue
    this.page.onSetElementText(this, newValue || "")
  }

  get nodeValue(): string | null {
    return this._nodeValue
  }

  set nodeValue(newValue: string | null) {
    this._nodeValue = newValue
    this.page.onSetElementText(this, newValue || "")
  }
}

export function isNZothNode(value: any): value is NZothNode {
  return "page" in value
}
