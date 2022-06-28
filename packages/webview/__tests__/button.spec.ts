import { mount } from "@vue/test-utils"
import Button from "../src/ui/components/Button.vue"

describe("button type", () => {
  test("button primary", () => {
    const wrapper = mount(Button, {
      props: {
        type: "primary"
      }
    })

    expect(wrapper.classes("ev-button--primary")).toBe(true)
  })
})

describe("button size", () => {
  test("button mini", () => {
    const wrapper = mount(Button, {
      props: {
        size: "mini"
      }
    })

    expect(wrapper.classes("ev-button--mini")).toBe(true)
  })
})
