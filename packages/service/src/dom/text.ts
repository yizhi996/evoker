import { EvokerPage } from "./page"
import { EvokerElement } from "./element"

export class EvokerText extends EvokerElement {
  constructor(textContent: string, page: EvokerPage) {
    super("", page)
    this.textContent = textContent
  }
}
