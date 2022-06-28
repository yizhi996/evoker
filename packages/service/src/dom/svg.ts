import { EvokerElement } from "./element"
import { EvokerPage } from "./page"

export class EvokerSVGElement extends EvokerElement {
  isSVG = true

  namespaceURI: string

  constructor(namespaceURI: string, tagName: string, page: EvokerPage) {
    super(tagName, page)

    this.namespaceURI = namespaceURI
  }
}
