import NZJSBridge from "./bridge"
import type { InvokeCallback } from "@nzoth/bridge"
import { pageScrollTo } from "./api/scroll"

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

NZJSBridge.subscribe<{ callbackId: number }>(
  Events.CALLBACK_APP_SERVICE,
  message => {
    const { callbackId } = message
    const callback = callbacks.get(callbackId)
    if (callback) {
      callback(message.message)
      callbacks.delete(callbackId)
    }
  }
)

const methods: Record<string, Function> = {
  pageScrollTo
}

NZJSBridge.subscribe<{ callbackId: number; event: string; params: any[] }>(
  Events.INVOKE_WEB_VIEW,
  message => {
    const { callbackId, event, params } = message
    const method = methods[event]
    if (method) {
      method.call(null, params || []).then((message: any) => {
        NZJSBridge.publish(
          Events.CALLBACL_WEB_VIEW,
          {
            message,
            callbackId
          },
          window.webViewId
        )
      })
    }
  }
)
