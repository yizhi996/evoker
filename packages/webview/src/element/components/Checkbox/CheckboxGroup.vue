<template>
  <nz-checkbox-group></nz-checkbox-group>
</template>

<script setup lang="ts">
import { getCurrentInstance, watch } from "vue"
import { useChildren } from "../../use/useRelation"
import { CHECKBOX_GROUP_KEY } from "./constant"

const props = withDefaults(defineProps<{
  modelValue?: unknown[]
  disabled?: boolean
  name?: string
}>(), {
  modelValue: () => []
})

const emit = defineEmits(["update:modelValue", "change"])

const instance = getCurrentInstance()!

const { children, linkChildren } = useChildren(instance, CHECKBOX_GROUP_KEY)

watch(() => [...children], () => {
  setChecked()
})

watch(() => [...props.modelValue], () => {
  setChecked()
})

const setChecked = () => {
  children.forEach(child => {
    const { childName, checked } = child as any
    checked.value = childName && props.modelValue.includes(childName)
  })
}

const updateGroupChecked = (name: unknown) => {
  const modelValue = props.modelValue as unknown[]
  const idx = modelValue.indexOf(name)
  if (idx > -1) {
    modelValue.splice(idx, 1)
  } else {
    modelValue.push(name)
  }
  instance.props.modelValue = [...modelValue]
  emitChange(modelValue)
}

linkChildren({
  updateGroupChecked
})

const formData = () => {
  return props.modelValue
}

const resetFormData = () => {
  instance.props.modelValue = []
  emitChange(instance.props.modelValue as unknown[])
}

const emitChange = (value: unknown[]) => {
  emit("update:modelValue", value)
  emit("change", value)
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
