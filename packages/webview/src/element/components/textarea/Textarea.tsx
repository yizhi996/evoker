import {
  PropType,
  ref,
  watch,
  watchEffect,
  onMounted,
  getCurrentInstance,
  defineComponent
} from "vue"
import { JSBridge } from "../../../bridge"
import { useTongceng } from "../../composables/useTongceng"
import { useKeyboard } from "../../composables/useKeyboard"
import { useTextArea } from "../../composables/useTextarea"
import { getInputStyle, getInputPlaceholderStyle } from "../../utils/style"
import { classNames } from "../../utils"

const props = {
  value: { type: String, default: "" },
  placeholder: { type: String, default: "" },
  placeholderStyle: { type: String, required: false },
  placeholderClass: { type: String, default: "ev-textarea__placeholder" },
  disabled: { type: Boolean, default: false },
  maxlength: { type: Number, default: 140 },
  focus: { type: Boolean, default: false },
  autoFocus: { type: Boolean, default: false },
  autoHeight: { type: Boolean, default: false },
  cursor: { type: Number, default: -1 },
  cursorSpacing: { type: Number, default: 0 },
  showConfirmBar: { type: Boolean, default: true },
  selectionStart: { type: Number, default: -1 },
  selectionEnd: { type: Number, default: -1 },
  adjustPosition: { type: Boolean, default: true },
  holdKeyboard: { type: Boolean, default: false },
  disableDefaultPadding: { type: Boolean, default: false },
  confirmType: {
    type: String as PropType<"send" | "search" | "next" | "go" | "done" | "return">,
    default: "return"
  },
  confirmHold: { type: Boolean, default: false }
}

export default defineComponent({
  name: "ev-textarea",
  props,
  emits: [
    "focus",
    "blur",
    "input",
    "confirm",
    "linechange",
    "keyboardheightchange",
    "update:value"
  ],
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const {
      tongcengKey,
      nativeId: inputId,
      tongcengRef,
      tongcengHeight,
      insertContainer,
      updateContainer,
      onUpdatedContainer
    } = useTongceng()

    const container = ref<HTMLElement>()
    const placeholderEl = ref<HTMLElement>()

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
      container.value!.style.height = data.height + "px"
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
          JSBridge.invoke<{ height: number; lineCount: number }>(
            "insertTextArea",
            {
              parentId: tongcengKey,
              inputId,
              text: props.value,
              style: getInputStyle(container.value!),
              placeholder: props.placeholder,
              placeholderStyle: getInputPlaceholderStyle(placeholderEl.value!),
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
                  container.value!.style.height = result.data.height + "px"
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
      JSBridge.invoke("operateInput", { inputId, method, data })
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

    onUpdatedContainer(() => {
      operateInput(OperateMethods.UPDATE_STYLE, getInputStyle(container.value!))
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

    expose({
      onTapLabel: () => {
        operateInput(OperateMethods.FOCUS)
      }
    })

    return () => (
      <ev-textarea ref={container}>
        <div ref={tongcengRef} class="ev-native__tongceng" id={tongcengKey}>
          <div style={{ width: "100%", height: tongcengHeight }}></div>
        </div>
        <p
          ref={placeholderEl}
          class={classNames("ev-textarea__placeholder", props.placeholderClass)}
          style={props.placeholderStyle}
        ></p>
      </ev-textarea>
    )
  }
})
