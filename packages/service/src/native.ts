import { isFunction } from "@vue/shared"
import { invokeAppOnError } from "./lifecycle/global"

const nativeTimer = globalThis.__AppServiceNativeSDK.timer

if (nativeTimer) {
  /** @ts-ignore */
  globalThis.invokeAppOnError = invokeAppOnError

  /** @ts-ignore */
  globalThis.setTimeout = (callback: (args: void) => void, ms?: number): NodeJS.Timer => {
    if (!isFunction(callback)) {
      throw new TypeError("setTimeout require a function as first argument")
    }
    return nativeTimer.setTimeout(callback, ms)
  }

  /** @ts-ignore */
  globalThis.clearTimeout = (timeoutId: NodeJS.Timer) => {
    nativeTimer.clearTimeout(timeoutId)
  }

  /** @ts-ignore */
  globalThis.setInterval = (callback: (args: void) => void, ms?: number): NodeJS.Timer => {
    if (!isFunction(callback)) {
      throw new TypeError("setInterval require a function as first argument")
    }
    return nativeTimer.setInterval(callback, ms)
  }

  /** @ts-ignore */
  globalThis.clearInterval = (timeoutId: NodeJS.Timer) => {
    nativeTimer.clearInterval(timeoutId)
  }
}
