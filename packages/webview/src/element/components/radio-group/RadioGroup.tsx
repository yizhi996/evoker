import { defineComponent } from "vue"
import { useChildren } from "../../use/useRelation"
import { RADIO_GROUP_KEY } from "../radio/constant"

const props = {
  name: { type: String, required: false }
}

export default defineComponent({
  name: "nz-radio-group",
  props,
  emits: ["change"],
  setup(_, { emit, expose }) {
    const { children, linkChildren } = useChildren(RADIO_GROUP_KEY)

    let checked: string = ""

    linkChildren({
      onChecked: (value: string, dispatch: boolean) => {
        if (checked !== value) {
          checked = value
          if (dispatch) {
            emit("change", { value })
          }
          children.forEach(child => {
            const { value: _value, setChecked } = child.exposed!
            setChecked(_value === value)
          })
        }
      }
    })

    expose({
      formData: () => checked,
      resetFormData: () => {
        children.forEach(child => {
          child.exposed!.setChecked(false)
        })
        checked = ""
        emit("change", { value: "" })
      }
    })

    return () => <nz-radio-group></nz-radio-group>
  }
})
