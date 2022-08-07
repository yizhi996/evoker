import { defineComponent, ref, nextTick, onMounted, watch, getCurrentInstance } from "vue"
import { classNames } from "../../utils"
import { props, emits } from "../input/Input"

export default defineComponent({
  name: "ek-input",
  props,
  emits,
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const inputEl = ref<HTMLInputElement>()

    const placeholderEl = ref<HTMLElement>()

    const focus = () => {
      inputEl.value && inputEl.value.focus()
    }

    onMounted(async () => {
      await nextTick()

      const rect = inputEl.value!.getBoundingClientRect()

      placeholderEl.value!.style.cssText += props.placeholderStyle
      placeholderEl.value!.style.lineHeight = rect.height + "px"
    })

    watch(
      () => props.placeholderStyle,
      () => {
        placeholderEl.value!.style.cssText += props.placeholderStyle
      }
    )

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

    expose({
      formData: () => props.value,
      resetFormData: () => {
        onInput("")
      },
      onTapLabel: () => {
        focus()
      }
    })

    return () => (
      <ek-input>
        <div class="ek-input__html__wrapper">
          <input
            ref={inputEl}
            class="ek-input__html"
            value={props.value}
            autofocus={props.focus}
            maxlength={props.maxlength}
            type={props.password ? "password" : "text"}
            onFocus={onFocus}
            onBlur={onBlur}
            onClick={focus}
            onInput={event => onInput((event.target! as HTMLInputElement).value)}
            disabled={props.disabled}
          ></input>
          <div
            ref={placeholderEl}
            v-show={!props.value}
            class={classNames("ek-input__html__placeholder", props.placeholderClass)}
          >
            {props.placeholder}
          </div>
        </div>
      </ek-input>
    )
  }
})
