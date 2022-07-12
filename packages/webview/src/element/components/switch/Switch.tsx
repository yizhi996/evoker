import { defineComponent, getCurrentInstance, PropType, VNode, withDirectives } from "vue"
import { vibrateShort } from "../../../bridge"
import { vTap } from "../../directive/tap"
import { classNames } from "../../utils"
import Icon from "../icon"

const props = {
  type: { type: String as PropType<"switch" | "checkbox">, default: "switch" },
  checked: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  color: { type: String, default: "#1989fa" },
  name: { type: String, required: false }
}

export default defineComponent({
  name: "ek-switch",
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
        return (
          <div class="ek-switch__wrapper">
            <div
              class={classNames("ek-switch__input", { "ek-switch__input--checked": checked })}
              style={{
                "border-color": checked ? color : "#dfdfdf",
                "background-color": checked ? color : "#fff"
              }}
            >
              <div class="ek-switch__input__background"></div>
              <div class="ek-switch__input__handle"></div>
            </div>
          </div>
        )
      }
    }

    return () => {
      const node = (
        <ek-switch class={{ "ek-switch--disabled": props.disabled }}>
          {renderType()}
          <span class="ek-switch__label"></span>
        </ek-switch>
      )
      return withDirectives(node as VNode, [[vTap, onClick, "", { stop: true }]])
    }
  }
})
