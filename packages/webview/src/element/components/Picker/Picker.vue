<template>
  <nz-picker v-tap.stop="onClick"></nz-picker>
</template>

<script setup lang="ts">
import { ref, computed } from "vue"
import { NZJSBridge } from "../../../bridge"
import { vTap } from "../../directive/tap"
import { PickerOption, PickerColumn, PickerObjectColumn } from "./define"


const props = withDefaults(defineProps<{
  mode: "selector" | "time" | "date"
  columns?: PickerOption[] | PickerColumn[]
  title?: string
  defaultIndex?: number
  start?: string
  end?: string
  value?: string
  name?: string
}>(), {
  mode: "selector",
  defaultIndex: 0,
  columns: () => []
})

let currentSelected: Record<string, any> = {}

const emit = defineEmits(["confirm", "cancel"])

const formattedColumns = ref<PickerObjectColumn[]>([])

const valuesKey = computed(() => {
  return "values"
})

const childrenKey = computed(() => {
  return "text"
})

const dataType = computed(() => {
  const firstColumn = props.columns[0]
  if (typeof firstColumn === 'object') {
    if (childrenKey.value in firstColumn) {
      return "cascade"
    }
    if (valuesKey.value in firstColumn) {
      return 'object'
    }
  }
  return 'plain'
})

const format = () => {
  if (dataType.value === 'plain') {
    formattedColumns.value = [{ [valuesKey.value]: props.columns, defaultIndex: props.defaultIndex }]
  } else if (dataType.value === 'cascade') {
    formatCascade()
  } else {
    formattedColumns.value = props.columns as PickerObjectColumn[]
  }
}

const formatCascade = () => {
  const formatted: PickerObjectColumn[] = []

  let cursor: PickerObjectColumn = {
    [childrenKey.value]: props.columns,
  };

  while (cursor && cursor[childrenKey.value]) {
    const children = cursor[childrenKey.value]
    let defaultIndex = cursor.defaultIndex ?? +props.defaultIndex

    while (children[defaultIndex] && children[defaultIndex].disabled) {
      if (defaultIndex < children.length - 1) {
        defaultIndex++
      } else {
        defaultIndex = 0
        break
      }
    }

    formatted.push({
      [valuesKey.value]: cursor[childrenKey.value],
      className: cursor.className,
      defaultIndex,
    })

    cursor = children[defaultIndex]
  }

  formattedColumns.value = formatted
}

const onClick = () => {
  if (props.mode === "time" || props.mode === "date") {
    NZJSBridge.invoke("showDatePickerView", {
      start: props.start,
      end: props.end,
      value: props.value,
      mode: props.mode,
      title: props.title
    }, result => {
      console.log(result)
      if (result.data === "cancel") {
        emit("cancel")
      } else {
        const value = result.data.value
        currentSelected = { value }
        emit("confirm", value)
      }
    })
  } if (props.mode === "selector") {
    format()
    NZJSBridge.invoke("showPickerView", {
      columns: formattedColumns.value,
      dataType: dataType.value,
      title: props.title,
    }, result => {
      if (result.data === "cancel") {
        emit("cancel")
      } else {
        if (dataType.value === "plain") {
          const index = result.data.index
          const value = result.data.value
          currentSelected = { index, value }
          emit("confirm", value, index)
        } else {
          const indexs = result.data.indexs
          const values = result.data.values
          currentSelected = { indexs, values }
          emit("confirm", values, indexs)
        }
      }
    })
  }
}

const formData = () => {
  return currentSelected
}

const resetFormData = () => {
  currentSelected = {}
  if (props.mode === "time" || props.mode === "date") {
    emit("confirm", "")
  } else if (dataType.value === "plain") {
    emit("confirm", "", 0)
  } else {
    emit("confirm", [], [])
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
