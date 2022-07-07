import { mount } from "@vue/test-utils"
import { expect, describe, it } from "vitest"
import Progress from "../src/element/components/progress"

describe("progress", () => {
  it("percent", () => {
    const progress = mount(Progress, {
      props: {
        percent: 50
      }
    })

    expect(progress.find(".ev-progress__active").attributes("style")).toContain("width: 50%")
  })

  it("showInfo", () => {
    const progress = mount(Progress, {
      props: {
        percent: 50,
        showInfo: true
      }
    })

    expect(progress.find(".ev-progress__value").text()).toContain("50%")
  })

  it("borderRadius", () => {
    const progress = mount(Progress, {
      props: {
        borderRadius: 10
      }
    })

    expect(progress.find(".ev-progress__track").attributes("style")).toContain(
      "border-radius: 10px"
    )
  })

  it("fontSize", () => {
    const progress = mount(Progress, {
      props: {
        showInfo: true,
        fontSize: 14
      }
    })

    expect(progress.find(".ev-progress__value").attributes("style")).toContain("font-size: 14px")
  })

  it("strokeWidth", () => {
    const progress = mount(Progress, {
      props: {
        strokeWidth: 5
      }
    })

    expect(progress.find(".ev-progress__track").attributes("style")).toContain("height: 5px")
  })

  it("activeColor", () => {
    const progress = mount(Progress, {
      props: {
        activeColor: "orange"
      }
    })

    expect(progress.find(".ev-progress__active").attributes("style")).toContain(
      "background-color: orange"
    )
  })

  it("backgroundColor", () => {
    const progress = mount(Progress, {
      props: {
        backgroundColor: "orange"
      }
    })

    expect(progress.find(".ev-progress__track").attributes("style")).toContain(
      "background-color: orange"
    )
  })
})
