<template>
  <nz-radio-group></nz-radio-group>
</template>

<script setup lang="ts">
import { getCurrentInstance, watch } from "vue"
import { useChildren } from "../../use/useRelation"
import { RADIO_GROUP_KEY } from "./constant"

const instance = getCurrentInstance()!

const props = defineProps<{
  modelValue?: unknown
  disabled?: boolean
  name?: string
}>()

const emit = defineEmits(["update:modelValue", "change"])

const { children, linkChildren } = useChildren(RADIO_GROUP_KEY)

watch(() => [...children], () => {
  setChecked()
})

watch(() => props.modelValue, () => {
  setChecked()
})

const setChecked = () => {
  children.forEach(child => {
    const { childName, setChecked } = child.exposed!
    setChecked(props.modelValue === childName)
  })
}

const updateGroupChecked = (name: unknown) => {
  instance.props.modelValue = name
  emit("update:modelValue", instance.props.modelValue)
  emit("change", instance.props.modelValue)
}

linkChildren({
  updateGroupChecked
})

const formData = () => {
  return props.modelValue
}

const resetFormData = () => {
  instance.props.modelValue = ""
  emit("update:modelValue", instance.props.modelValue)
  emit("change", instance.props.modelValue)
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
