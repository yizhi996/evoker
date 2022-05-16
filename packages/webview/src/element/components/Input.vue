<template>
  <nz-input ref="rootRef">
    <div ref="containerRef" class="nz-native__container" :id="tongcengKey">
      <div ref="innerRef" style="width: 100%" :style="height"></div>
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
import { ref, onMounted, watch, watchEffect, getCurrentInstance } from "vue"
import useNative from "../use/useNative"
import useKeyboard from "../listener/keyboard"
import { getInputStyle, getInputPlaceholderStyle } from "../utils/style"
import { NZJSBridge } from "../../bridge"

const instance = getCurrentInstance()!

const emit = defineEmits([
  "focus",
  "blur",
  "input",
  "confirm",
  "keyboard-height-change",
  "update:value"
])

const props = withDefaults(
  defineProps<{
    value?: string
    type?: "text" | "number" | "digit"
    password?: boolean
    placeholder?: string
    placeholderStyle?: string
    placeholderClass?: string
    disabled?: boolean
    maxlength?: number
    cursorSpacing?: number
    focus?: boolean
    confirmType?: "send" | "search" | "next" | "go" | "done"
    confirmHold?: boolean
    cursor?: number
    selectionStart?: number
    selectionEnd?: number
    adjustPosition?: boolean
    holdKeyboard?: boolean
    name?: string
  }>(),
  {
    value: "",
    type: "text",
    password: false,
    placeholder: "",
    placeholderClass: "nz-input__placeholder",
    disabled: false,
    maxlength: 140,
    cursorSpacing: 0,
    focus: false,
    confirmType: "done",
    confirmHold: false,
    cursor: -1,
    selectionStart: -1,
    selectionEnd: -1,
    adjustPosition: true,
    holdKeyboard: false
  }
)

const {
  tongcengKey,
  nativeId: inputId,
  containerRef,
  innerRef,
  height,
  insertContainer,
  onUpdatedContainer
} = useNative()

const {
  onKeyboardSetValue,
  onKeyboardShow,
  onKeyboardHide,
  onKeyboardConfirm,
  onKeyboardHeightChange
} = useKeyboard(inputId)

const rootRef = ref<HTMLElement>()
const placeholderRef = ref<HTMLElement>()

const onInput = (value: string) => {
  emit("update:value", value)
  emit("input", { value })
}

onKeyboardSetValue(data => {
  instance.props.value = data.value
  onInput(data.value)
})

onKeyboardShow(() => {
  emit("focus", { value: props.value })
})

onKeyboardHide(() => {
  emit("blur", { value: props.value })
})

onKeyboardConfirm(() => {
  emit("confirm", { value: props.value })
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
  insertContainer(success => {
    if (success) {
      NZJSBridge.invoke("insertInput", {
        parentId: tongcengKey,
        inputId,
        text: props.value,
        style: getInputStyle(rootRef.value!),
        placeholder: props.placeholder,
        placeholderStyle: getInputPlaceholderStyle(placeholderRef.value!),
        focus: props.focus,
        confirmType: props.confirmType,
        maxlength: props.maxlength,
        password: props.password,
        type: props.type,
        adjustPosition: props.adjustPosition,
        disabled: props.disabled,
        cursor: props.cursor,
        selectionStart: props.selectionStart,
        selectionEnd: props.selectionEnd,
        confirmHold: props.confirmHold,
        holdKeyboard: props.holdKeyboard,
        cursorSpacing: props.cursorSpacing
      })
    }
  })
}

const enum OperateMethods {
  CHANGE_VALUE = "changeValue",
  FOCUS = "focus",
  BLUR = "blur",
  UPDATE = "update",
  UPDATE_STYLE = "updateStyle",
  UPDATE_PLACEHOLDER_STYLE = "updatePlaceholderStyle"
}

const operateInput = (method: OperateMethods, data: Record<string, any> = {}) => {
  NZJSBridge.invoke("operateInput", { inputId, method, data })
}

watch(
  () => props.value,
  () => {
    changeValue()
  }
)

const changeValue = () => {
  operateInput(OperateMethods.CHANGE_VALUE, { text: props.value })
}

watch(
  () => props.focus,
  () => {
    props.focus ? operateInput(OperateMethods.FOCUS) : operateInput(OperateMethods.BLUR)
  }
)

watch(
  () => props.placeholderClass,
  () => {
    operateInput(
      OperateMethods.UPDATE_PLACEHOLDER_STYLE,
      getInputPlaceholderStyle(placeholderRef.value!)
    )
  }
)

watch(
  () => props.placeholderStyle,
  () => {
    operateInput(
      OperateMethods.UPDATE_PLACEHOLDER_STYLE,
      getInputPlaceholderStyle(placeholderRef.value!)
    )
  }
)

onUpdatedContainer(() => {
  operateInput(OperateMethods.UPDATE_STYLE, getInputStyle(rootRef.value!))
})

watchEffect(() => {
  operateInput(OperateMethods.UPDATE, {
    placeholder: props.placeholder,
    confirmType: props.confirmType,
    maxlength: props.maxlength,
    password: props.password,
    type: props.type,
    adjustPosition: props.adjustPosition,
    disabled: props.disabled,
    cursor: props.cursor,
    selectionStart: props.selectionStart,
    selectionEnd: props.selectionEnd,
    confirmHold: props.confirmHold,
    holdKeyboard: props.holdKeyboard,
    cursorSpacing: props.cursorSpacing
  })
})

const formData = () => {
  return props.value
}

const resetFormData = () => {
  instance.props.value = ""
  onInput("")
  changeValue()
}

defineExpose({
  formData,
  resetFormData,
  onTapLabel: () => {
    operateInput(OperateMethods.FOCUS)
  }
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
