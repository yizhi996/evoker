import nz from "./bridge"
import useApp from "./lifecycle/useApp"
import usePage from "./lifecycle/usePage"
import "./native"
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
Function.prototype.constructor = hijack as FunctionConstructor
;(Function as any) = hijack

const { withModifiers } = Vue
extend(Vue, {
  withModifiers: (fn: Function, modifiers: string[]) => {
    const wrapper = withModifiers(fn, modifiers) as ReturnType<typeof withModifiers> & {
      modifiers?: string[]
    }
    wrapper.modifiers = modifiers
    return wrapper
  }
})
