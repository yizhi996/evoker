import { EvokerPage } from "../../src/dom/page"
import { EvokerHTMLElement } from "../../src/dom/html"

test("node clone", () => {
  const page = new EvokerPage(0, "test", 0)

  const el = new EvokerHTMLElement("div", page)
  el.style.setProperty("width", "100px")

  const clone = el.cloneNode(true) as EvokerHTMLElement
  clone.style.setProperty("heigt", "100px")

  expect(clone.style.cssText).not.toBe(el.style.cssText)
})
