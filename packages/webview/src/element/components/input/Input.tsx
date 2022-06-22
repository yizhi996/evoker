import {
  ref,
  onMounted,
  watch,
  watchEffect,
  getCurrentInstance,
  PropType,
  defineComponent
} from "vue"
import useNative from "../../use/useNative"
import useKeyboard from "../../listener/keyboard"
import { getInputStyle, getInputPlaceholderStyle } from "../../utils/style"
import { NZJSBridge } from "../../../bridge"

const props = {
  value: { type: String, default: "" },
  type: { type: String as PropType<"text" | "number" | "digit">, default: "text" },
  password: { type: Boolean, default: false },
  placeholder: { type: String, default: "" },
  placeholderStyle: { type: String, required: false },
  placeholderClass: { type: String, default: "nz-input__placeholder" },
  disabled: { type: Boolean, default: false },
  maxlength: { type: Number, default: 140 },
  cursorSpacing: { type: Number, default: 0 },
  focus: { type: Boolean, default: false },
  confirmType: {
    type: String as PropType<"send" | "search" | "next" | "go" | "done">,
    default: "done"
  },
  confirmHold: { type: Boolean, default: false },
  cursor: { type: Number, default: -1 },
  selectionStart: { type: Number, default: -1 },
  selectionEnd: { type: Number, default: -1 },
  adjustPosition: { type: Boolean, default: true },
  holdKeyboard: { type: Boolean, default: false }
}

export default defineComponent({
  name: "nz-input",
  props,
  emits: ["focus", "blur", "input", "confirm", "keyboard-height-change", "update:value"],
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const {
      tongcengKey,
      nativeId: inputId,
      tongcengRef,
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

    const container = ref<HTMLElement>()
    const placeholderEl = ref<HTMLElement>()

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
            style: getInputStyle(container.value!),
            placeholder: props.placeholder,
            placeholderStyle: getInputPlaceholderStyle(placeholderEl.value!),
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
          getInputPlaceholderStyle(placeholderEl.value!)
        )
      }
    )

    watch(
      () => props.placeholderStyle,
      () => {
        operateInput(
          OperateMethods.UPDATE_PLACEHOLDER_STYLE,
          getInputPlaceholderStyle(placeholderEl.value!)
        )
      }
    )

    const changeValue = () => {
      operateInput(OperateMethods.CHANGE_VALUE, { text: props.value })
    }

    onUpdatedContainer(() => {
      operateInput(OperateMethods.UPDATE_STYLE, getInputStyle(container.value!))
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

    expose({
      formData: () => props.value,
      resetFormData: () => {
        instance.props.value = ""
        onInput("")
        changeValue()
      },
      onTapLabel: () => {
        operateInput(OperateMethods.FOCUS)
      }
    })

    return () => {
      const placeholderClass = "nz-input__placeholder " + props.placeholderClass

      return (
        <nz-input ref={container}>
          <div ref={tongcengRef} class="nz-native__tongceng" id={tongcengKey}>
            <div style={{ width: "100%", height: height }}></div>
          </div>
          <p ref={placeholderEl} class={placeholderClass} style={props.placeholderStyle}></p>
        </nz-input>
      )
    }
  }
})
