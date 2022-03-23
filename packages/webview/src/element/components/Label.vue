<template>
  <nz-label ref="labelRef" v-tap.stop="onTap"></nz-label>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { vTap } from "../directive/tap"
import { isNZothElement } from "../../dom/element"

const props = defineProps<{ for?: string }>()

const labelRef = ref<HTMLElement>()

const validTags = [
  "NZ-BUTTON",
  "NZ-INPUT",
  "NZ-TEXTAREA",
  "NZ-SWITCH",
  "NZ-RADIO",
  "NZ-CHECKBOX"
]

const onTap = () => {
  if (props.for) {
    const el = document.getElementById(props.for)
    if (isNZothElement(el) && validTags.includes(el.tagName)) {
      const { onTapLabel } = el.__instance.exposed!
      onTapLabel()
    }
  } else {
    dfsTapLabelTarget(labelRef.value!)
  }
}

const dfsTapLabelTarget = (el: HTMLElement) => {
  const childNodes = el.childNodes
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i]
    if (isNZothElement(node) && validTags.includes(node.tagName)) {
      const { onTapLabel } = node.__instance.exposed!
      onTapLabel()
    } else {
      dfsTapLabelTarget(node as HTMLElement)
    }
  }
}

</script>
