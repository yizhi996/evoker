import { onSync, publish } from "@nzoth/bridge"
import { SyncFlags } from "@nzoth/shared"
import {
  insertBefore,
  setText,
  removeChild,
  setDisplay,
  addEventListener,
  updateProp,
  setModelValue
} from "./render"
import { selector } from "./selector"
import { addIntersectionObserver, removeIntersectionObserver } from "./intersection"

let firstRender = false

onSync(message => {
  const start = Date.now()
  message.forEach((action: any[]) => {
    render(action)
  })
  if (!firstRender) {
    firstRender = true
    publish("WEBVIEW_FIRST_RENDER", { timestamp: Date.now() - start }, window.webViewId)
  }
})

const renderFunction: { [x: number]: Function } = {
  [SyncFlags.INSERT]: insertBefore,
  [SyncFlags.SET_TEXT]: setText,
  [SyncFlags.REMOVE]: removeChild,
  [SyncFlags.DISPLAY]: setDisplay,
  [SyncFlags.ADD_EVENT]: addEventListener,
  [SyncFlags.UPDATE_PROP]: updateProp,
  [SyncFlags.SET_MODEL_VALUE]: setModelValue,
  [SyncFlags.SELECTOR]: selector,
  [SyncFlags.ADD_INTERSECTION_OBSERVER]: addIntersectionObserver,
  [SyncFlags.REMOVE_INTERSECTION_OBSERVER]: removeIntersectionObserver
}

function render(data: any[]) {
  const flag = data[0] as SyncFlags
  const fn = renderFunction[flag]
  fn && fn(data)
}
