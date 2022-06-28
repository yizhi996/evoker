import { EvokerPage } from "./page"
import { EvokerEventTarget } from "./eventTarget"
import { EvokerHTMLElement } from "./html"
import { EvokerCSSStyleDeclaration } from "./style"
import { extend } from "@vue/shared"

export class EvokerNode extends EvokerEventTarget {
  page: EvokerPage

  nodeId: number = 0

  parentNode?: EvokerNode
  anchorNode?: EvokerNode | null

  childNodes: EvokerNode[]

  isMounted = false

  private _textContent: string | null = null
  private _nodeValue: string | null = null

  constructor(page: EvokerPage) {
    super()
    this.page = page
    this.page.appendChildNode(this)
    this.childNodes = []
  }

  insertBefore(child: EvokerNode, anchor?: EvokerNode | null): EvokerNode {
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

  removeChild(child: EvokerNode): EvokerNode {
    child.parentNode = undefined
    const i = this.childNodes.indexOf(child)
    if (i > -1) {
      this.childNodes.splice(i, 1)
    }
    this.page.onRemove(this, child)
    child.isMounted = false
    return child
  }

  cloneNode(deep?: boolean): EvokerNode {
    const clone = extend(Object.create(Object.getPrototypeOf(this)), this) as EvokerHTMLElement
    clone.isMounted = false

    const { attributes, style } = clone

    if (attributes) {
      clone.attributes = extend(Object.create(null), attributes)
    }

    if (style) {
      clone.style = new EvokerCSSStyleDeclaration(clone)
      clone.style._style = extend(Object.create(null), style._style)
    }

    if (deep) {
      clone.childNodes = clone.childNodes.map(childNode => childNode.cloneNode(true))
    }

    return clone
  }

  get firstChild(): EvokerNode | null {
    return this.childNodes[0]
  }

  get lastChild(): EvokerNode | null {
    return this.childNodes[this.childNodes.length - 1]
  }

  get nextSibling(): EvokerNode | null {
    if (this.parentNode) {
      const { childNodes } = this.parentNode
      return childNodes[childNodes.indexOf(this) + 1]
    }
    return null
  }

  get previousSibling(): EvokerNode | null {
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

export function isEvokerNode(value: any): value is EvokerNode {
  return "page" in value
}
