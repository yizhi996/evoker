import { defineComponent } from "vue"
import { useChildren } from "../../composables/useRelation"
import { CHECKBOX_GROUP_KEY } from "../checkbox/constant"

const props = {
  name: { type: String, required: false }
}

export default defineComponent({
  name: "ev-checkbox-group",
  props,
  emits: ["change"],
  setup(_, { emit, expose }) {
    const { children, linkChildren } = useChildren(CHECKBOX_GROUP_KEY)

    let checkeds: Record<string, boolean> = {}

    linkChildren({
      onChecked: (value: string, checked: boolean, dispatch: boolean) => {
        checkeds[value] = checked
        dispatch && emit("change", { value: getValue() })
      }
    })

    const getValue = () => {
      const res: string[] = []
      for (const [value, checked] of Object.entries(checkeds)) {
        checked && res.push(value)
      }
      return res
    }

    expose({
      formData: () => getValue(),
      resetFormData: () => {
        checkeds = {}
        children.forEach(child => {
          const { setChecked } = child.exposed!
          setChecked(false)
        })
        emit("change", { value: [] })
      }
    })

    return () => <ev-checkbox-group></ev-checkbox-group>
  }
})
