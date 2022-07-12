import { computed, defineComponent, PropType, VNode, watch, withDirectives } from "vue"
import { JSBridge } from "../../../bridge"
import { vTap } from "../../directive/tap"
import { isObject } from "@vue/shared"

const props = {
  headerText: { type: String, required: false },
  mode: {
    type: String as PropType<"selector" | "multiSelector" | "time" | "date">,
    default: "selector"
  },
  range: { type: Array, default: () => [] }, // for selector | multiSelector
  rangeKey: { type: String, required: false }, // for selector | multiSelector
  value: { type: [Number, Array, String], default: 0 }, // for selector | multiSelector | time
  start: { type: String, required: false }, // for time | date
  end: { type: String, required: false }, // for time | date
  disabled: { type: Boolean, default: false },
  name: { type: String, required: false }
}

export default defineComponent({
  name: "ek-picker",
  props,
  emits: ["change", "columnchange", "cancel"],
  setup(props, { emit, expose }) {
    let isShow = false

    watch(
      () => [...props.range],
      () => {
        updateMultiPickerView({
          columns: formatData.value,
          current: props.value
        })
      }
    )

    const dataType = computed(() => {
      if (props.mode === "multiSelector") {
        const firstColumns = props.range[0] as unknown[]
        return isObject(firstColumns[0]) ? "object" : "plain"
      } else {
        return isObject(props.range[0]) ? "object" : "plain"
      }
    })

    const formatData = computed(() => {
      if (props.mode === "multiSelector") {
        let result: string[][] = []
        const range = props.range as unknown[][]
        if (dataType.value === "object") {
          const key = props.rangeKey
          range.forEach(col => {
            if (key) {
              result.push((col as Record<string, any>[]).map(item => item[key] + ""))
            } else {
              result.push(col.map(item => item + ""))
            }
          })
        } else {
          range.forEach(col => result.push(col.map(item => item + "")))
        }
        return result
      } else if (dataType.value === "object") {
        const key = props.rangeKey
        if (key) {
          return (props.range as Record<string, any>[]).map(item => item[key] + "")
        } else {
          return props.range.map(item => item + "")
        }
      } else {
        return props.range
      }
    })

    const onClick = () => {
      if (props.disabled) {
        return
      }
      if (props.mode === "time" || props.mode === "date") {
        isShow = true
        JSBridge.invoke<{ value: string }>(
          "showDatePickerView",
          {
            start: props.start,
            end: props.end,
            value: props.value,
            mode: props.mode,
            title: props.headerText
          },
          result => {
            if (result.data) {
              result.data.value === "cancel"
                ? emit("cancel")
                : emit("change", { value: result.data.value })
            }
          }
        )
      } else if (props.mode === "selector") {
        isShow = true
        JSBridge.invoke<{ value: number }>(
          "showPickerView",
          {
            columns: formatData.value,
            title: props.headerText,
            current: props.value
          },
          result => {
            isShow = false
            if (result.data) {
              result.data.value === -1
                ? emit("cancel")
                : emit("change", { value: result.data.value })
            }
          }
        )
      } else if (props.mode === "multiSelector") {
        isShow = true
        JSBridge.invoke<{ value: number[] | string }>(
          "showMultiPickerView",
          {
            columns: formatData.value,
            title: props.headerText,
            current: props.value
          },
          result => {
            isShow = false
            if (result.data) {
              result.data.value === "cancel"
                ? emit("cancel")
                : emit("change", { value: result.data.value })
            }
          }
        )
        JSBridge.subscribe<{ column: number; value: number }>(
          "WEBVIEW_MULTI_PICKER_COLUMN_CHANGE",
          result => {
            if (isShow) {
              emit("columnchange", { column: result.column, value: result.value })
            }
          }
        )
      }
    }

    const updateMultiPickerView = (data: Record<string, any>) => {
      if (props.mode === "multiSelector" && isShow) {
        JSBridge.invoke("updateMultiPickerView", data)
      }
    }

    expose({
      formData: () => {
        return { value: props.value }
      },
      resetFormData: () => {
        if (props.mode === "time" || props.mode === "date") {
          emit("change", { value: "" })
        } else if (props.mode === "multiSelector") {
          const value = new Array((props.value as number[]).length).fill(0)
          emit("change", { value })
        } else {
          emit("change", { value: 0 })
        }
      }
    })

    return () => {
      const node = <ek-picker></ek-picker>

      return withDirectives(node as VNode, [[vTap, onClick]])
    }
  }
})
