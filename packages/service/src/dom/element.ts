import { EvokerPage } from "./page"
import { EvokerNode } from "./node"

export class EvokerElement extends EvokerNode {
  id = ""

  readonly tagName: string

  className = ""

  attributes: Record<string, unknown> = Object.create(null)

  constructor(tagName: string, page: EvokerPage) {
    super(page)
    this.tagName = tagName
  }

  setAttribute(name: string, value: any) {
    this.attributes[name] = value
    this.page.onPatchProp(this, name, value)
  }

  removeAttribute(name: string): void {
    delete this.attributes[name]
    this.page.onPatchProp(this, name)
  }

  setAttributeNS(namespace: string, name: string, value: any): void {
    this.attributes[namespace + name] = value
    this.page.onPatchProp(this, name, value)
  }

  removeAttributeNS(namespace: string, name: string): void {
    delete this.attributes[namespace + name]
    this.page.onPatchProp(this, name)
  }
}
