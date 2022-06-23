import { defineComponent, ref } from "vue"
import { isNZothElement } from "../../../dom/element"

const validTags = [
  "NZ-INPUT",
  "NZ-SWITCH",
  "NZ-SLIDER",
  "NZ-RADIO-GROUP",
  "NZ-CHECKBOX-GROUP",
  "NZ-PICKER"
]

export default defineComponent({
  name: "nz-form",
  emits: ["submit", "reset"],
  setup(_, { emit, expose }) {
    const container = ref<HTMLElement>()

    let formData: Record<string, any> = Object.create(null)

    const getFormData = (el: HTMLElement) => {
      const childNodes = el.childNodes
      for (let i = 0; i < childNodes.length; i++) {
        const node = childNodes[i]
        if (isNZothElement(node) && validTags.includes(node.tagName)) {
          const name = node.__instance.props.name as string
          if (name) {
            const exposed = node.__instance.exposed!
            const data = exposed.formData()
            formData[name] = data
          }
        }
        getFormData(node as HTMLElement)
      }
    }

    const resetFormData = (el: HTMLElement) => {
      if (el.childNodes) {
        const childNodes = el.childNodes
        for (let i = 0; i < childNodes.length; i++) {
          const node = childNodes[i]
          if (isNZothElement(node) && validTags.includes(node.tagName)) {
            const exposed = node.__instance.exposed!
            exposed.resetFormData()
          }
          resetFormData(node as HTMLElement)
        }
      }
    }

    expose({
      onSubmit: () => {
        formData = Object.create(null)
        container.value && getFormData(container.value)
        emit("submit", { value: formData })
      },
      onReset: () => {
        formData = Object.create(null)
        container.value && resetFormData(container.value)
        emit("reset", {})
      }
    })

    return () => <nz-form ref={container}></nz-form>
  }
})
