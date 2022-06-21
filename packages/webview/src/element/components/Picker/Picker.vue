<template>
  <nz-picker v-tap="onClick"></nz-picker>
</template>

<script setup lang="ts">
import { computed, watch } from "vue"
import { NZJSBridge } from "../../../bridge"
import { vTap } from "../../directive/tap"
import { isObject } from "@vue/shared"

const emit = defineEmits(["change", "columnchange", "cancel"])

const props = withDefaults(
  defineProps<{
    headerText?: string
    mode: "selector" | "multiSelector" | "time" | "date"
    // for selector | multiSelector
    range?: any[]
    // for selector | multiSelector
    rangeKey?: string
    // for selector | multiSelector | time
    value?: number | number[] | string
    // for time | date
    start?: string
    // for time | date
    end?: string
    disabled?: boolean
    name?: string
  }>(),
  {
    mode: "selector",
    disabled: false,
    range: () => [],
    value: 0
  }
)

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
    const firstColumns = props.range[0]
    return isObject(firstColumns[0]) ? "object" : "plain"
  } else {
    return isObject(props.range[0]) ? "object" : "plain"
  }
})

const formatData = computed(() => {
  if (props.mode === "multiSelector") {
    let result: string[][] = []
    if (dataType.value === "object") {
      const key = props.rangeKey
      props.range.forEach((col: any[]) => {
        if (key) {
          result.push(col.map(item => item[key] + ""))
        } else {
          result.push(col.map(item => item + ""))
        }
      })
    } else {
      props.range.forEach((col: any[]) => {
        result.push(col.map(item => item + ""))
      })
    }
    return result
  } else if (dataType.value === "object") {
    const key = props.rangeKey
    if (key) {
      return props.range.map(item => item[key] + "")
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
    NZJSBridge.invoke<{ value: string }>(
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
    NZJSBridge.invoke<{ value: number }>(
      "showPickerView",
      {
        columns: formatData.value,
        title: props.headerText,
        current: props.value
      },
      result => {
        isShow = false
        if (result.data) {
          result.data.value === -1 ? emit("cancel") : emit("change", { value: result.data.value })
        }
      }
    )
  } else if (props.mode === "multiSelector") {
    isShow = true
    NZJSBridge.invoke<{ value: number[] | string }>(
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
    NZJSBridge.subscribe<{ column: number; value: number }>(
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
    NZJSBridge.invoke("updateMultiPickerView", data)
  }
}

const formData = () => {
  return { value: props.value }
}

const resetFormData = () => {
  if (props.mode === "time" || props.mode === "date") {
    emit("change", { value: "" })
  } else if (props.mode === "multiSelector") {
    const value = new Array((props.value as number[]).length).fill(0)
    emit("change", { value })
  } else {
    emit("change", { value: 0 })
  }
}

defineExpose({
  formData,
  resetFormData
})
</script>

<style>
nz-picker {
  display: block;
}
</style>
