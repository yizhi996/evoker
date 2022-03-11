import nz from "./bridge"
import useApp from "./lifecycle/useApp"
import usePage from "./lifecycle/usePage"
import "./timer"
import Vue from "vue"
import { extend } from "@vue/shared"

export { useApp, usePage }
export { createApp } from "./app"
export { defineRouter } from "./router"
export { nz }
export * from "./bridge"

function hijack() {
  return {}
}

hijack.prototype = Function.prototype
Function.prototype.constructor = hijack
;(Function as any) = hijack

const _withModifiers = Vue.withModifiers
const withModifiers = (fn: Function, modifiers: string[]) => {
  const wrapper = _withModifiers(fn, modifiers) as ReturnType<
    typeof Vue.withModifiers
  > & {
    modifiers?: string[]
  }
  wrapper.modifiers = modifiers
  return modifiers
}
extend(Vue, { withModifiers })
