import NZJSBridge from "./bridge"
import type { InvokeCallback } from "@nzoth/bridge"
import { pageScrollTo } from "./api/scroll"
import { loadFontFace } from "./api/font"

let callbackId = 0

const callbacks = new Map<number, InvokeCallback<any>>()

const enum Events {
  INVOKE_APP_SERVICE = "invokeAppServiceMethod",
  CALLBACK_APP_SERVICE = "callbackAppServiceMethod",
  INVOKE_WEB_VIEW = "invokeWebViewMethod",
  CALLBACL_WEB_VIEW = "callbackWebViewMethod"
}

export function invokeAppServiceMethod<T = unknown>(
  event: string,
  params: any = {},
  callback?: InvokeCallback<T>
) {
  const cbId = callbackId++
  NZJSBridge.publish(
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

NZJSBridge.subscribe<{ callbackId: number; result: any }>(Events.CALLBACK_APP_SERVICE, message => {
  const { callbackId, result } = message
  const callback = callbacks.get(callbackId)
  if (callback) {
    callback(result)
    callbacks.delete(callbackId)
  }
})

const methods: Record<string, Function> = {
  pageScrollTo,
  loadFontFace
}

NZJSBridge.subscribe<{ callbackId: number; event: string; params: any[] }>(
  Events.INVOKE_WEB_VIEW,
  message => {
    const { callbackId, event, params } = message
    const method = methods[event]
    if (method) {
      method
        .call(null, params || [])
        .then((result: any) => {
          NZJSBridge.publish(
            Events.CALLBACL_WEB_VIEW,
            {
              result: { errMsg: "", data: result },
              callbackId
            },
            window.webViewId
          )
        })
        .catch((error: string) => {
          NZJSBridge.publish(
            Events.CALLBACL_WEB_VIEW,
            {
              result: { errMsg: error, data: {} },
              callbackId
            },
            window.webViewId
          )
        })
    }
  }
)
