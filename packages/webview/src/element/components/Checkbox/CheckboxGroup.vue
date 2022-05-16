<template>
  <nz-checkbox-group></nz-checkbox-group>
</template>

<script setup lang="ts">
import { useChildren } from "../../use/useRelation"
import { CHECKBOX_GROUP_KEY } from "./constant"

const emit = defineEmits(["change"])

defineProps<{
  name?: string
}>()

const { children, linkChildren } = useChildren(CHECKBOX_GROUP_KEY)

let checkeds: Record<string, boolean> = {}

linkChildren({
  onChecked: (value: string, checked: boolean, dispatch: boolean) => {
    checkeds[value] = checked
    dispatch && emit("change", { value: getValue() })
  }
})

const getValue = () => {
  let res = []
  for (const [value, checked] of Object.entries(checkeds)) {
    checked && res.push(value)
  }
  return res
}

const formData = () => {
  return getValue()
}

const resetFormData = () => {
  checkeds = {}
  children.forEach(child => {
    const { setChecked } = child.exposed!
    setChecked(false)
  })
  emit("change", { value: [] })
}

defineExpose({
  formData,
  resetFormData
})
</script>

<style>
nz-checkbox-group {
  display: block;
}
</style>
