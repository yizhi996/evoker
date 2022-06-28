import { EvokerCSSStyleDeclaration } from "./style"
import { EvokerElement } from "./element"
import { EvokerPage } from "./page"

export type Style = string | Record<string, string | string[]> | null

export class EvokerHTMLElement extends EvokerElement {
  style: EvokerCSSStyleDeclaration

  constructor(tagName: string, page: EvokerPage) {
    super(tagName, page)

    this.style = new EvokerCSSStyleDeclaration(this)
  }
}
