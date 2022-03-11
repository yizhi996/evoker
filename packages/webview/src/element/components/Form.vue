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
  "NZ-CHECKBOX",
  "NZ-CHECKBOX-GROUP",
  "NZ-PICKER"
]

const getFormData = (el: HTMLElement) => {
  const childNodes = el.childNodes
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i]
    if (isNZothElement(node) && node.__instance) {
      if (validTags.includes(node.tagName)) {
        const name = node.__instance.props.name as string
        if (name) {
          const exposed = node.__instance.exposed!
          const setData = () => {
            const data = exposed.formData()
            formData[name] = data
          }
          if (node.tagName === "NZ-CHECKBOX") {
            !exposed.group && setData()
          } else {
            setData()
          }
        }
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
      if (isNZothElement(node) && node.__instance) {
        if (validTags.includes(node.tagName)) {
          const exposed = node.__instance.exposed!
          exposed.resetFormData()
        }
      }
      resetFormData(node as HTMLElement)
    }
  }
}

const onSubmit = () => {
  formData = Object.create(null)
  containerRef.value && getFormData(containerRef.value)
  emit("submit", formData)
}

const onReset = () => {
  formData = Object.create(null)
  containerRef.value && resetFormData(containerRef.value)
  emit("reset", formData)
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