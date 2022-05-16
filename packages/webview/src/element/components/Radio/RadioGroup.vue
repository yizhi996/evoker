<template>
  <nz-radio-group></nz-radio-group>
</template>

<script setup lang="ts">
import { useChildren } from "../../use/useRelation"
import { RADIO_GROUP_KEY } from "./constant"

defineProps<{
  name?: string
}>()

const emit = defineEmits(["change"])

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

const formData = () => {
  return checked
}

const resetFormData = () => {
  children.forEach(child => {
    child.exposed!.setChecked(false)
  })
  checked = ""
  emit("change", { value: "" })
}

defineExpose({
  formData,
  resetFormData
})
</script>

<style>
nz-radio-group {
  display: block;
}
</style>
