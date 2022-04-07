<template>
  <nz-switch v-tap.stop="onClick" :class="disabled ? 'nz-switch--disabled' : ''">
    <icon v-if="type === 'checkbox'" :type="checked ? 'success' : 'circle'" :color="color" />
    <div v-else class="nz-switch__wrapper">
      <div
        class="nz-switch__input"
        :class="checked ? 'nz-switch__input--checked' : ''"
        :style="{
          'border-color': checked ? color : '#dfdfdf',
          'background-color': checked ? color : '#fff'
        }"
      >
        <div class="nz-switch__input__background"></div>
        <div class="nz-switch__input__handle"></div>
      </div>
    </div>
    <span class="nz-switch__label"></span>
  </nz-switch>
</template>

<script setup lang="ts">
import { vibrateShort } from "../../bridge"
import { getCurrentInstance } from "vue"
import { vTap } from "../directive/tap"
import Icon from "./Icon.vue"

const instance = getCurrentInstance()!

const emit = defineEmits(["update:checked", "change"])

const props = withDefaults(defineProps<{
  type?: "switch" | "checkbox"
  checked?: boolean
  disabled?: boolean
  color?: string
  name?: string
}>(), {
  type: "switch",
  checked: false,
  disabled: false,
  color: "#1989fa"
})

const onClick = () => {
  if (props.disabled) {
    return
  }
  setChecked(!props.checked)
  vibrateShort({ type: "light" })
}

const formData = () => {
  return props.checked
}

const resetFormData = () => {
  setChecked(false)
}

const setChecked = (checked: boolean) => {
  instance.props.checked = checked
  emit("update:checked", checked)
  emit("change", { value: checked })
}

defineExpose({
  formData,
  resetFormData,
  onTapLabel: () => {
    onClick()
  }
})

</script>

<style lang="less">
nz-switch {
  -webkit-tap-highlight-color: transparent;
  display: inline-block;
}

.nz-switch {
  &--disabled {
    opacity: 0.5;
  }

  &__wrapper {
    display: inline-flex;
    align-items: center;
    vertical-align: middle;
  }

  &__input {
    background-color: #dfdfdf;
    border: 1px solid #dfdfdf;
    border-radius: 16px;
    box-sizing: border-box;
    width: 52px;
    height: 32px;
    margin-right: 5px;
    outline: 0;
    position: relative;
    transition: background-color 0.1s, border 0.1s;

    &__background {
      position: absolute;
      width: 50px;
      height: 30px;
      left: 0;
      top: 0;
      border-radius: 15px;
      background-color: #fff;
      transition: transform 0.3s;
    }

    &__handle {
      position: absolute;
      width: 30px;
      height: 30px;
      left: 0;
      top: 0;
      border-radius: 15px;
      background-color: #fff;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
      transition: transform 0.3s;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &--checked &__handle {
      transform: translateX(20px);
    }

    &--checked &__background {
      transform: scale(0);
    }
  }
}
</style>
