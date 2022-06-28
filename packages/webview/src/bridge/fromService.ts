import JSBridge from "./bridge"
import type { InvokeCallback } from "@evoker/bridge"
import { pageScrollTo } from "./api/scroll"
import { loadFontFace } from "./api/font"
import { isEvokerElement, nodes } from "../dom/element"

let callbackId = 0

const callbacks = new Map<number, InvokeCallback<any>>()

const enum Events {
  INVOKE_APP_SERVICE = "invokeAppServiceMethod",
  CALLBACK_APP_SERVICE = "callbackAppServiceMethod",
  INVOKE_WEB_VIEW = "invokeWebViewMethod",
  CALLBACK_WEB_VIEW = "callbackWebViewMethod"
}

export function invokeAppServiceMethod<T = unknown>(
  event: string,
  params: any = {},
  callback?: InvokeCallback<T>
) {
  const cbId = callbackId++
  JSBridge.publish(
    Events.INVOKE_APP_SERVICE,
    {
      event,
      params,
      callbackId: cbId
    },
    window.webViewId
  )
  if (callback) {
    callbacks.set(cbId, callback)
  }
}

JSBridge.subscribe<{ callbackId: number; result: any }>(Events.CALLBACK_APP_SERVICE, message => {
  const { callbackId, result } = message
  const callback = callbacks.get(callbackId)
  if (callback) {
    callback(result)
    callbacks.delete(callbackId)
  }
})

interface OperateContextOptions {
  nodeId: number
  method: string
  data: Record<string, any>
}

const operateContext = (options: OperateContextOptions) => {
  const node = nodes.get(options.nodeId)
  if (node && isEvokerElement(node.el)) {
    node.el.__instance!.exposed!.operate(options)
  }
  return Promise.resolve({})
}

const methods: Record<string, Function> = {
  pageScrollTo,
  loadFontFace,
  operateContext
}

JSBridge.subscribe<{ callbackId: number; event: string; params: any[] }>(
  Events.INVOKE_WEB_VIEW,
  message => {
    const { callbackId, event, params } = message
    const method = methods[event]
    const publish = (result: any) => {
      JSBridge.publish(Events.CALLBACK_WEB_VIEW, { result, callbackId }, window.webViewId)
    }
    if (method) {
      method
        .call(null, params || {})
        .then((result: any) => {
          publish({ errMsg: "", data: result })
        })
        .catch((error: string) => {
          publish({ errMsg: error, data: {} })
        })
    } else {
      publish({ errMsg: "this method not defined with webview", data: {} })
    }
  }
)
