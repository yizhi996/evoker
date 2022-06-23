import {
  nextTick,
  watch,
  onMounted,
  getCurrentInstance,
  defineComponent,
  withDirectives,
  VNode
} from "vue"
import Icon from "../icon"
import { vTap } from "../../directive/tap"
import { useParent, ParentProvide } from "../../composables/useRelation"
import { CHECKBOX_GROUP_KEY, CheckboxProvide } from "./constant"

const props = {
  value: { type: String },
  checked: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  color: { type: String, default: "#1989fa" }
}

export default defineComponent({
  name: "nz-checkbox",
  props,
  setup(props, { expose }) {
    const instance = getCurrentInstance()!

    let group: ParentProvide<CheckboxProvide> | undefined

    onMounted(() => {
      nextTick(() => {
        group = useParent(instance, CHECKBOX_GROUP_KEY)
        onChecked(false)
      })
    })

    watch(
      () => props.checked,
      () => {
        onChecked(false)
      }
    )

    const onClick = () => {
      if (props.disabled) {
        return
      }
      instance.props.checked = !instance.props.checked
      onChecked(true)
    }

    const onChecked = (dispatch: boolean) => {
      props.value && group && group.onChecked(props.value, props.checked, dispatch)
    }

    expose({
      value: props.value,
      getChecked: () => props.checked,
      setChecked: (checked: boolean) => {
        instance.props.checked = checked
      },
      onTapLabel: () => {
        onClick()
      }
    })

    return () => {
      const node = (
        <nz-checkbox class={{ "nz-checkbox--disabled": props.disabled }}>
          <Icon type={props.checked ? "success" : "circle"} color={props.color} />
          <span class="nz-checkbox__label"></span>
        </nz-checkbox>
      )

      return withDirectives(node as VNode, [[vTap, onClick, "", { stop: true }]])
    }
  }
})
