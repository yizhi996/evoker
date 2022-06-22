import { defineComponent, getCurrentInstance, PropType, VNode, withDirectives } from "vue"
import { vibrateShort } from "../../../bridge"
import { vTap } from "../../directive/tap"
import Icon from "../icon"

const props = {
  type: { type: String as PropType<"switch" | "checkbox">, default: "switch" },
  checked: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  color: { type: String, default: "#1989fa" },
  name: { type: String, required: false }
}

export default defineComponent({
  name: "nz-switch",
  props,
  emits: ["update:checked", "change"],
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const onClick = () => {
      if (props.disabled) {
        return
      }
      setChecked(!props.checked)
      vibrateShort({ type: "light" })
    }

    const setChecked = (checked: boolean) => {
      instance.props.checked = checked
      emit("update:checked", checked)
      emit("change", { value: checked })
    }

    expose({
      formData: () => props.checked,
      resetFormData: () => {
        setChecked(false)
      },
      onTapLabel: () => {
        onClick()
      }
    })

    const renderType = () => {
      const { checked, color } = props
      if (props.type === "checkbox") {
        return <Icon type={checked ? "success" : "circle"} color={color} />
      } else {
        const cls = "nz-switch__input " + (checked ? "nz-switch__input--checked" : "")
        return (
          <div class="nz-switch__wrapper">
            <div
              class={cls}
              style={{
                "border-color": checked ? color : "#dfdfdf",
                "background-color": checked ? color : "#fff"
              }}
            >
              <div class="nz-switch__input__background"></div>
              <div class="nz-switch__input__handle"></div>
            </div>
          </div>
        )
      }
    }

    return () => {
      const node = (
        <nz-switch class={props.disabled ? "nz-switch--disabled" : ""}>
          {renderType()}
          <span class="nz-switch__label"></span>
        </nz-switch>
      )
      return withDirectives(node as VNode, [[vTap, onClick, "", { stop: true }]])
    }
  }
})
