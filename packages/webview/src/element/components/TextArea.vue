<template>
  <nz-textarea ref="rootRef">
    <div ref="containerRef" class="nz-native__container" :id="tongcengKey">
      <div ref="innerRef" style="width: 100%;" :style="height"></div>
    </div>
    <p
      ref="placeholderRef"
      class="nz-textarea__placeholder"
      :class="placeholderClass"
      :style="placeholderStyle"
    ></p>
  </nz-textarea>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue"
import { NZJSBridge } from "../../bridge"
import useNative from "../use/useNative"
import useKeyboard from "../listener/keyboard"
import useTextArea from "../listener/textarea"
import { getInputStyle, getInputPlaceholderStyle } from "../utils/style"

const emit = defineEmits(["focus", "blur", "input", "confirm", "linechenge", "keyboardheightchange", "update:modelValue"])

const props = withDefaults(defineProps<{
  modelValue: string
  placeholder?: string
  disabled?: boolean
  focus?: boolean
  confirmType?: "send" | "search" | "next" | "go" | "done" | "return"
  maxlength?: number
  autoHeight?: boolean
  adjustPosition?: boolean
  disableDefaultPadding?: boolean
  placeholderClass?: string
  placeholderStyle?: string
}>(), {
  placeholder: "",
  disabled: false,
  focus: false,
  confirmType: "done",
  maxlength: 140,
  adjustPosition: true,
  autoHeight: false,
  disableDefaultPadding: false,
  placeholderClass: "textarea-placeholder"
})

const { tongcengKey, nativeId: inputId, containerRef, innerRef, height, insertContainer, updateContainer } = useNative()

const { onKeyboardSetValue, onKeyboardShow, onKeyboardHide, onKeyboardConfirm } = useKeyboard(inputId)

const { onTextAreaHeightChange } = useTextArea(inputId)

const rootRef = ref<HTMLElement>()
const placeholderRef = ref<HTMLElement>()

onKeyboardSetValue(data => {
  const value = data.value
  if (value !== props.modelValue) {
    emit("update:modelValue", value)
    emit("input", value)
  }
})

onKeyboardShow(() => {
  emit("focus")
})

onKeyboardHide(() => {
  emit("blur")
})

onKeyboardConfirm(() => {
  emit("confirm")
})

onTextAreaHeightChange(data => {
  rootRef.value!.style.height = data.height + "px"
  updateContainer()
})

onMounted(() => {
  setTimeout(() => {
    insert()
  })
})

const insert = () => {
  insertContainer((success) => {
    if (success) {
      NZJSBridge.invoke("insertTextArea", {
        parentId: tongcengKey,
        inputId,
        text: props.modelValue,
        style: getInputStyle(rootRef.value!),
        placeholder: props.placeholder,
        placeholderStyle: getInputPlaceholderStyle(placeholderRef.value!),
        focus: props.focus,
        confirmType: props.confirmType,
        maxlength: props.maxlength,
        adjustPosition: props.adjustPosition,
        autoHeight: props.autoHeight,
        disableDefaultPadding: props.disableDefaultPadding
      })
    }
  })
}

defineExpose({
  onTapLabel: () => {
    NZJSBridge.invoke("operateInput", {
      inputId,
      method: "becomeFirstResponder",
      data: {}
    })
  }
})
</script>

<style lang="less">
nz-textarea {
  display: block;
  position: relative;
  width: 300px;
  height: 150px;
  cursor: auto;
  overflow: hidden;
}

.nz-textarea {
  &__placeholder {
    color: gray;
    display: none;
  }
}
</style>
