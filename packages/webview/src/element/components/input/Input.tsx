import {
  ref,
  onMounted,
  watch,
  watchEffect,
  getCurrentInstance,
  PropType,
  defineComponent,
  nextTick
} from "vue"
import { useTongceng } from "../../composables/useTongceng"
import { useKeyboard } from "../../composables/useKeyboard"
import { getInputStyle, getInputPlaceholderStyle } from "../../utils/style"
import { JSBridge } from "../../../bridge"
import { classNames } from "../../utils"

export const props = {
  value: { type: String, default: "" },
  type: { type: String as PropType<"text" | "number" | "digit">, default: "text" },
  password: { type: Boolean, default: false },
  placeholder: { type: String, default: "" },
  placeholderStyle: { type: String, required: false },
  placeholderClass: { type: String, default: "ek-input__placeholder" },
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
  holdKeyboard: { type: Boolean, default: false },
  name: { type: String, required: false }
}

export const emits = ["focus", "blur", "input", "confirm", "keyboard-height-change", "update:value"]

export default defineComponent({
  name: "ek-input",
  props,
  emits: emits,
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const {
      tongcengKey,
      nativeId: inputId,
      tongcengRef,
      tongcengHeight,
      insertContainer,
      onUpdatedContainer
    } = useTongceng()

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
      instance.props.value = value
      emit("update:value", value)
      emit("input", { value })
    }

    const onFocus = () => {
      emit("focus", { value: props.value })
    }

    const onBlur = () => {
      emit("blur", { value: props.value })
    }

    onKeyboardSetValue(data => {
      onInput(data.value)
    })

    onKeyboardShow(onFocus)

    onKeyboardHide(onBlur)

    onKeyboardConfirm(() => {
      emit("confirm", { value: props.value })
    })

    onKeyboardHeightChange(data => {
      emit("keyboard-height-change", { height: data.height, duration: data.duration })
    })

    onMounted(async () => {
      await nextTick()
      setTimeout(() => {
        insert()
      })
    })

    const insert = () => {
      insertContainer(success => {
        if (success) {
          JSBridge.invoke("insertInput", {
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
      JSBridge.invoke("operateInput", { inputId, method, data })
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
        onInput("")
        changeValue()
      },
      onTapLabel: () => {
        operateInput(OperateMethods.FOCUS)
      }
    })

    return () => (
      <ek-input ref={container}>
        <div ref={tongcengRef} class="ek-tongceng" id={tongcengKey}>
          <div style={{ width: "100%", height: tongcengHeight }}></div>
        </div>
        <p
          ref={placeholderEl}
          class={classNames("ek-input__placeholder", props.placeholderClass)}
          style={[props.placeholderStyle || {}, { display: "none" }]}
        ></p>
      </ek-input>
    )
  }
})
