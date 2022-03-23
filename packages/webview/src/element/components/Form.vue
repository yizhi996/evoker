<template>
  <nz-form ref="containerRef">
    <slot></slot>
  </nz-form>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { isNZothElement } from "../../dom/element"

const emit = defineEmits(["submit", "reset"])

const containerRef = ref<HTMLElement>()

let formData: Record<string, any> = Object.create(null)

const validTags = [
  "NZ-INPUT",
  "NZ-SWITCH",
  "NZ-SLIDER",
  "NZ-RADIO-GROUP",
  "NZ-CHECKBOX-GROUP",
  "NZ-PICKER"
]

const getFormData = (el: HTMLElement) => {
  const childNodes = el.childNodes
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i]
    if (isNZothElement(node) && validTags.includes(node.tagName)) {
      const name = node.__instance.props.name as string
      if (name) {
        const exposed = node.__instance.exposed!
        const data = exposed.formData()
        formData[name] = data
      }
    }
    getFormData(node as HTMLElement)
  }
}

const resetFormData = (el: HTMLElement) => {
  if (el.childNodes) {
    const childNodes = el.childNodes
    for (let i = 0; i < childNodes.length; i++) {
      const node = childNodes[i]
      if (isNZothElement(node) && validTags.includes(node.tagName)) {
        const exposed = node.__instance.exposed!
        exposed.resetFormData()
      }
      resetFormData(node as HTMLElement)
    }
  }
}

const onSubmit = () => {
  formData = Object.create(null)
  containerRef.value && getFormData(containerRef.value)
  emit("submit", { value: formData })
}

const onReset = () => {
  formData = Object.create(null)
  containerRef.value && resetFormData(containerRef.value)
  emit("reset", {})
}

defineExpose({
  onSubmit,
  onReset
})

</script>

<style>
nz-form {
  width: 100%;
}
</style>