import { NZothHTMLElement } from "./html"

export class NZothCSSStyleDeclaration {
  element: NZothHTMLElement

  _style: Record<string, string>

  constructor(element: NZothHTMLElement) {
    this.element = element
    this._style = Object.create(null)
  }

  get styleObject(): Record<string, string> {
    return this._style
  }

  get cssText(): string {
    let css = ""
    for (const [name, value] of Object.entries(this._style)) {
      css += `${name}: ${value};`
    }
    return css
  }

  set cssText(newValue: string) {
    for (const css of newValue.split(";")) {
      const kv = css.split(":")
      if (kv) {
        const key = kv[0].trim()
        if (key) {
          let value: string | null = null
          if (kv.length === 2) {
            value = kv[1].trim()
          }
          this.setProperty(key, value)
        }
      }
    }
  }

  get display() {
    return this._style.display
  }

  set display(newValue: string) {
    this._style.display = newValue
    this.element.page && this.element.page.onShow(this.element)
  }

  cleanAll() {
    this._style = Object.create(null)
  }

  setProperty(property: string, value: string | null, priority?: string) {
    if (value) {
      this._style[property] = value
    } else {
      delete this._style[property]
    }
  }
}
