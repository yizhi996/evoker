import { mount } from "@vue/test-utils"
import { expect, it, describe } from "vitest"
import Button from "../src/element/components/button"

describe("button", () => {
  it("type", () => {
    const button = mount(Button, {
      props: {
        type: "primary"
      }
    })

    expect(button.classes("ev-button--primary")).toBe(true)
  })

  it("size", () => {
    const button = mount(Button, {
      props: {
        size: "mini"
      }
    })

    expect(button.classes("ev-button--size-mini")).toBe(true)
  })

  it("color", () => {
    const button = mount(Button, {
      props: {
        color: "orange"
      }
    })

    expect(button.attributes("style")).toContain("background-color: orange;")
  })

  it("plain", () => {
    const button = mount(Button, {
      props: {
        plain: true,
        color: "orange"
      }
    })

    expect(button.attributes("style")).toContain("color: orange;")
  })

  it("loading", () => {
    const button = mount(Button, {
      props: {
        loading: true
      }
    })

    expect(button.find(".ev-loading").exists()).toBe(true)
  })
})
