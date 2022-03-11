import { NZothCSSStyleDeclaration } from "./style"
import { NZothElement } from "./element"
import { NZothPage } from "./page"

export type Style = string | Record<string, string | string[]> | null

export class NZothHTMLElement extends NZothElement {
  style: NZothCSSStyleDeclaration

  constructor(tagName: string, page: NZothPage) {
    super(tagName, page)

    this.style = new NZothCSSStyleDeclaration(this)
  }
}
