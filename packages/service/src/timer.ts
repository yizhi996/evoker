const nativeTimer = globalThis.__NZAppServiceNativeSDK.timer

if (nativeTimer) {
  globalThis.setTimeout = (
    callback: (args: void) => void,
    ms?: number
  ): NodeJS.Timer => {
    if (typeof callback != "function") {
      throw new TypeError("setTimeout require a function as first argument")
    }
    return nativeTimer.setTimeout(callback, ms)
  }

  globalThis.clearTimeout = (timeoutId: NodeJS.Timer) => {
    nativeTimer.clearTimeout(timeoutId)
  }

  globalThis.setInterval = (
    callback: (args: void) => void,
    ms?: number
  ): NodeJS.Timer => {
    if (typeof callback != "function") {
      throw new TypeError("setInterval require a function as first argument")
    }
    return nativeTimer.setInterval(callback, ms)
  }

  globalThis.clearInterval = (timeoutId: NodeJS.Timer) => {
    nativeTimer.clearInterval(timeoutId)
  }
}
