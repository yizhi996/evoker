import { isFunction } from "@nzoth/shared"

const nativeTimer = globalThis.__NZAppServiceNativeSDK.timer

if (nativeTimer) {
  /** @ts-ignore */
  globalThis.setTimeout = (callback: (args: void) => void, ms?: number): NodeJS.Timer => {
    if (!isFunction(callback)) {
      throw new TypeError("setTimeout require a function as first argument")
    }
    return nativeTimer.setTimeout(callback, ms)
  }

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

  globalThis.clearInterval = (timeoutId: NodeJS.Timer) => {
    nativeTimer.clearInterval(timeoutId)
  }
}
