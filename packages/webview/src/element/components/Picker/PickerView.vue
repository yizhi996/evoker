<template>
  <nz-picker-view></nz-picker-view>
</template>

<script setup lang="ts">
import { computed, ref, watch } from "vue"
import { PickerOption, PickerColumn, PickerObjectColumn, ColumnsFieldNames } from "./define"

const emit = defineEmits(["confirm", "cancel", "change"])

const props = withDefaults(defineProps<{
  columns?: PickerOption[] | PickerColumn[]
  columnsFieldNames?: ColumnsFieldNames
  confirmButtonText?: string
  cancelButtonText?: string
  loading?: boolean
  showToolbar?: boolean
  defaultIndex?: number
  itemHeight?: number
}>(), {
  columns: () => [],
  columnsFieldNames: () => {
    return { text: "text", values: "values", children: "children" }
  },
  confirmButtonText: "确认",
  cancelButtonText: "取消",
  loading: false,
  showToolbar: true,
  defaultIndex: 0,
  itemHeight: 44
})


</script>

<style>
nz-picker-view {
  display: block;
}
</style>