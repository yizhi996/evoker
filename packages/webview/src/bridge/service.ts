import NZJSBridge from "./bridge"
import { InvokeCallback } from "@nzoth/bridge"

let callbackId = 0

const callbacks = new Map<number, InvokeCallback>()

export function invokeAppServiceMethod(
  event: string,
  params: any = {},
  callback?: InvokeCallback
) {
  const cbId = ++callbackId
  NZJSBridge.publish(
    "invokeAppServiceMethod",
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

NZJSBridge.subscribe("callbackAppServiceMethod", message => {
  const { callbackId } = message
  const callback = callbacks.get(callbackId)
  if (callback) {
    callback(message.message)
    callbacks.delete(callbackId)
  }
})
