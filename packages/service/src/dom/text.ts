import { NZothPage } from "./page"
import { NZothElement } from "./element"

export class NZothText extends NZothElement {
  constructor(textContent: string, page: NZothPage) {
    super("", page)
    this.textContent = textContent
  }
}
