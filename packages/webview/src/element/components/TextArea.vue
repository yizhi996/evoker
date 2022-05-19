<template>
  <nz-textarea ref="rootRef">
    <div ref="tongcengRef" class="nz-native__tongceng" :id="tongcengKey">
      <div style="width: 100%" :style="height"></div>
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
import { ref, watch, watchEffect, onMounted, getCurrentInstance } from "vue"
import { NZJSBridge } from "../../bridge"
import useNative from "../use/useNative"
import useKeyboard from "../listener/keyboard"
import useTextArea from "../listener/textarea"
import { getInputStyle, getInputPlaceholderStyle } from "../utils/style"

const instance = getCurrentInstance()!

const emit = defineEmits([
  "focus",
  "blur",
  "input",
  "confirm",
  "linechange",
  "keyboardheightchange",
  "update:value"
])

const props = withDefaults(
  defineProps<{
    value?: string
    placeholder?: string
    placeholderStyle?: string
    placeholderClass?: string
    disabled?: boolean
    maxlength?: number
    autoFocus?: boolean
    focus?: boolean
    autoHeight?: boolean
    fixed?: boolean
    cursorSpacing?: number
    cursor?: number
    showConfirmBar?: boolean
    selectionStart?: number
    selectionEnd?: number
    adjustPosition?: boolean
    holdKeyboard?: boolean
    disableDefaultPadding?: boolean
    confirmType?: "send" | "search" | "next" | "go" | "done" | "return"
    confirmHold?: boolean
  }>(),
  {
    value: "",
    placeholder: "",
    placeholderClass: "nz-textarea__placeholder",
    disabled: false,
    maxlength: 140,
    autoFocus: false,
    focus: false,
    autoHeight: false,
    fixed: false,
    cursorSpacing: 0,
    cursor: -1,
    selectionStart: -1,
    selectionEnd: -1,
    showConfirmBar: true,
    adjustPosition: true,
    holdKeyboard: false,
    disableDefaultPadding: false,
    confirmType: "return",
    confirmHold: false
  }
)

const {
  tongcengKey,
  nativeId: inputId,
  tongcengRef,
  height,
  insertContainer,
  updateContainer,
  onUpdatedContainer
} = useNative()

const rootRef = ref<HTMLElement>()
const placeholderRef = ref<HTMLElement>()

const onInput = (value: string) => {
  emit("update:value", value)
  emit("input", { value })
}

const {
  onKeyboardSetValue,
  onKeyboardShow,
  onKeyboardHide,
  onKeyboardConfirm,
  onKeyboardHeightChange
} = useKeyboard(inputId)

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
  emit("keyboardheightchange", { height: data.height, duration: data.duration })
})

const { onTextAreaHeightChange } = useTextArea(inputId)

onTextAreaHeightChange(data => {
  rootRef.value!.style.height = data.height + "px"
  emit("linechange", { height: data.height, lineCount: data.lineCount })
  updateContainer()
})

onMounted(() => {
  setTimeout(() => {
    insert()
  })
})

const insert = () => {
  insertContainer(success => {
    if (success) {
      NZJSBridge.invoke<{ height: number; lineCount: number }>(
        "insertTextArea",
        {
          parentId: tongcengKey,
          inputId,
          text: props.value,
          style: getInputStyle(rootRef.value!),
          placeholder: props.placeholder,
          placeholderStyle: getInputPlaceholderStyle(placeholderRef.value!),
          focus: props.focus,
          confirmType: props.confirmType,
          maxlength: props.maxlength,
          adjustPosition: props.adjustPosition,
          autoHeight: props.autoHeight,
          disableDefaultPadding: props.disableDefaultPadding,
          disabled: props.disabled,
          cursor: props.cursor,
          selectionStart: props.selectionStart,
          selectionEnd: props.selectionEnd,
          confirmHold: props.confirmHold,
          holdKeyboard: props.holdKeyboard,
          cursorSpacing: props.cursorSpacing,
          showConfirmBar: props.showConfirmBar
        },
        result => {
          if (result.data) {
            if (props.autoHeight) {
              rootRef.value!.style.height = result.data.height + "px"
              updateContainer()
            }
          }
        }
      )
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
  () => props.autoFocus,
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
    adjustPosition: props.adjustPosition,
    disabled: props.disabled,
    cursor: props.cursor,
    selectionStart: props.selectionStart,
    selectionEnd: props.selectionEnd,
    confirmHold: props.confirmHold,
    holdKeyboard: props.holdKeyboard,
    cursorSpacing: props.cursorSpacing,
    showConfirmBar: props.showConfirmBar,
    autoHeight: props.autoHeight,
    disableDefaultPadding: props.disableDefaultPadding
  })
})

defineExpose({
  onTapLabel: () => {
    operateInput(OperateMethods.FOCUS)
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
