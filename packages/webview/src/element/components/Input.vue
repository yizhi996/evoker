<template>
  <nz-input ref="rootRef">
    <div ref="containerRef" class="nz-native__container" :id="tongcengKey">
      <div ref="innerRef" style="width: 100%;" :style="height"></div>
    </div>
    <p
      ref="placeholderRef"
      class="nz-input__placeholder"
      :class="placeholderClass"
      :style="placeholderStyle"
    ></p>
  </nz-input>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, getCurrentInstance } from "vue"
import useNative from "../use/useNative"
import useKeyboard from "../listener/keyboard"
import { getInputStyle, getInputPlaceholderStyle } from "../utils/style"
import { NZJSBridge } from "../../bridge"

const instance = getCurrentInstance()!

const props = withDefaults(defineProps<{
  modelValue?: string
  type?: "text" | "number" | "digit"
  password?: boolean
  focus?: boolean
  placeholder?: string
  confirmType?: "send" | "search" | "next" | "go" | "done"
  maxlength?: number
  adjustPosition?: boolean
  placeholderClass?: string
  placeholderStyle?: string
  disabled?: boolean
  name?: string
}>(), {
  modelValue: "",
  type: "text",
  password: false,
  focus: false,
  placeholder: "",
  confirmType: "done",
  maxlength: 140,
  adjustPosition: true,
  placeholderClass: "input-placeholder",
  disabled: false
})

const emit = defineEmits(["focus", "blur", "input", "confirm", "keyboard-height-change", "update:modelValue"])

const { tongcengKey, nativeId: inputId, containerRef, innerRef, height, insertContainer } = useNative()

const { onKeyboardSetValue, onKeyboardShow, onKeyboardHide, onKeyboardConfirm, onKeyboardHeightChange } = useKeyboard(inputId)

const rootRef = ref<HTMLElement>()
const placeholderRef = ref<HTMLElement>()

watch(() => props.modelValue, () => {
  updateValue()
})

onKeyboardSetValue(data => {
  emit("update:modelValue", data.value)
  emit("input", data.value)
})

onKeyboardShow(() => {
  emit("focus", props.modelValue)
})

onKeyboardHide(() => {
  emit("blur", props.modelValue)
})

onKeyboardConfirm(() => {
  emit("confirm", props.modelValue)
})

onKeyboardHeightChange(data => {
  emit("keyboard-height-change", { height: data.height, duration: data.duration })
})

onMounted(() => {
  setTimeout(() => {
    insert()
  })
})

const insert = () => {
  insertContainer((success) => {
    if (success) {
      NZJSBridge.invoke("insertInput", {
        parentId: tongcengKey,
        inputId,
        text: props.modelValue,
        style: getInputStyle(rootRef.value!),
        placeholder: props.placeholder,
        placeholderStyle: getInputPlaceholderStyle(placeholderRef.value!),
        focus: props.focus,
        confirmType: props.confirmType,
        maxlength: props.maxlength,
        password: props.password,
        type: props.type,
        adjustPosition: props.adjustPosition,
        disabled: props.disabled
      })
    }
  })
}

const updateValue = () => {
  NZJSBridge.invoke("operateInput", {
    inputId,
    method: "changeValue",
    data: {
      text: props.modelValue,
    }
  })
}

const formData = () => {
  return props.modelValue
}

const resetFormData = () => {
  instance.props.modelValue = ""
  emit("update:modelValue", instance.props.modelValue)
  emit("input", instance.props.modelValue)
  updateValue()
}

defineExpose({
  formData,
  resetFormData
})
</script>

<style lang="less">
nz-input {
  cursor: auto;
  display: block;
  width: 100%;
  height: 1.4rem;
  overflow: hidden;
  text-overflow: clip;
  white-space: nowrap;
}

nz-input,
nz-input input {
  font-family: UICTFontTextStyleBody;
  min-height: 1.4rem;
}

.nz-input {
  &__placeholder {
    color: gray;
    display: none;
  }
}
</style>
