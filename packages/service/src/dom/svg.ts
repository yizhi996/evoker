import { NZothElement } from "./element"
import { NZothPage } from "./page"

export class NZothSVGElement extends NZothElement {
  isSVG = true

  namespaceURI: string

  constructor(namespaceURI: string, tagName: string, page: NZothPage) {
    super(tagName, page)

    this.namespaceURI = namespaceURI
  }
}
