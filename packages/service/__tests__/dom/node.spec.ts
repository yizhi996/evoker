import { NZothPage } from "../../src/dom/page"
import { NZothHTMLElement } from "../../src/dom/html"

test("node clone", () => {
  const page = new NZothPage(0, "test", 0)

  const el = new NZothHTMLElement("div", page)
  el.style.setProperty("width", "100px")

  const clone = el.cloneNode(true) as NZothHTMLElement
  clone.style.setProperty("heigt", "100px")

  expect(clone.style.cssText).not.toBe(el.style.cssText)
})
