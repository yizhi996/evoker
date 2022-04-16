import "./dom/vdSync"
import "./dom/selector"
import "./dom/intersection"

export { injectComponent } from "./element"

document.addEventListener("DOMContentLoaded", () => {
  const that = window as any
  if (that.webkit) {
    that.webkit.messageHandlers.DOMContentLoaded.postMessage({
      timestamp: Date.now()
    })
  }
})
