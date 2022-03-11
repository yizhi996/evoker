<template>
  <nz-button ref="buttonRef" :class="classes" :style="styleses">
    <div class="nz-button__content">
      <loading v-if="loading" style="margin-right: 5px"></loading>
      <div id="content">
        <slot></slot>
      </div>
    </div>
  </nz-button>
</template>

<script setup lang="ts">
import { computed, watch, nextTick } from "vue"
import { NZothElement } from "../../dom/element";
import { addTap } from "../../dom/event";
import { isTrue } from "../../utils"
import useHover from "../use/useHover"
import Loading from "./Loading.vue"

const props = withDefaults(defineProps<{
  type?: "primary" | "default" | "success" | "warning" | "danger"
  size?: "large" | "normal" | "small" | "mini"
  color?: string
  plain?: boolean
  disabled?: boolean
  loading?: boolean
  hoverClass?: string
  hoverStopPropagation?: boolean
  hoverStartTime?: number
  hoverStayTime?: number,
  formType?: "submit" | "reset"
}>(), {
  type: "default",
  size: "normal",
  color: "",
  plain: false,
  disabled: false,
  loading: false,
  hoverClass: "nz-button--hover",
  hoverStopPropagation: false,
  hoverStartTime: 20,
  hoverStayTime: 70
})

const { viewRef: buttonRef, finalHoverClass } = useHover(props)

const classes = computed(() => {
  let cls = "nz-button "
  cls += `nz-button--${props.type} `
  cls += `nz-button--${props.size} `
  if (isTrue(props.disabled)) {
    cls += "nz-button--disabled "
  }
  if (props.plain) {
    cls += `nz-button--${props.type}--plain `
  }
  cls += `${finalHoverClass.value}`
  return cls
})

const styleses = computed(() => {
  let style = ""
  if (props.color) {
    style += props.plain ? `color: ${props.color};` : `background-color: ${props.color};`
    style += `border: 1px solid ${props.color};`
  }
  return style
})

const findForm = (el: HTMLElement): NZothElement | undefined => {
  const parent = el.parentElement
  if (parent) {
    if (parent.tagName === "NZ-FORM") {
      return parent as NZothElement
    }
    return findForm(parent)
  }
}

let clickEventRemove: Function

watch(() => props.formType, (formType) => {
  clickEventRemove && clickEventRemove()
  if (formType === "submit" || formType === "reset") {
    nextTick(() => {
      if (buttonRef.value) {
        const button = buttonRef.value
        clickEventRemove = addTap(button, {}, args => {
          const form = findForm(button)
          if (form && form.__instance) {
            const expose = form.__instance.exposed!
            if (formType === "submit") {
              expose.onSubmit()
            } else if (formType === "reset") {
              expose.onReset()
            }
          }
        })
      }
    })
  }
}, {
  immediate: true
})

</script>

<style lang="less">
nz-button {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  text-align: center;
  border-radius: 4px;
  min-height: 48px;
  margin: 15px auto;
  font-weight: bold;
  font-size: 17px;
  transition: opacity 0.2s;
  padding: 8px 24px;
}

.nz-button {
  &--primary {
    color: #fff;
    background-color: #1989fa;
    border: 1px solid #1989fa;
  }

  &--primary--plain {
    background-color: white;
    color: #1989fa;
  }

  &--success {
    color: #fff;
    background-color: #07c160;
    border: 1px solid #07c160;
  }

  &--success--plain {
    background-color: white;
    color: #07c160;
  }

  &--default {
    color: #323233;
    background-color: #fff;
    border: 1px solid #ebedf0;
  }

  &--default--plain {
    color: #323233;
    border: 1px solid #323233;
  }

  &--danger {
    color: #fff;
    background-color: #ee0a24;
    border: 1px solid #ee0a24;
  }

  &--danger--plain {
    background-color: white;
    color: #ee0a24;
  }

  &--warning {
    color: #fff;
    background-color: #ff976a;
    border: 1px solid #ff976a;
  }

  &--large {
    width: 100%;
    min-height: 54px;
    font-size: 19px;
  }

  &--normal {
    width: 184px;
  }

  &--small {
    min-height: 36px;
    font-size: 14px;
    width: auto;
    display: inline-block;
    padding: 6px 12px;
  }

  &--mini {
    min-height: 28px;
    font-size: 12px;
    width: auto;
    display: inline-block;
    padding: 4px 12px;
  }

  &--disabled {
    opacity: 0.5;
  }

  &--hover {
    box-shadow: inset 0 0 100px 100px rgba(0, 0, 0, 0.1);
  }

  &__content {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
  }
}
</style>
