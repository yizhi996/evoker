import { isString } from "@vue/shared"

let callbackId = 0

export type InvokeCallback<T> = (result: InvokeCallbackResult<T>) => void

export interface InvokeCallbackResult<T = Record<string, any>> {
  id: number
  event: string
  errMsg: string
  data?: T
}

const callbacks = new Map<number, InvokeCallback<any>>()

export function invoke<T = unknown>(
  event: string,
  params: Record<string, any> = {},
  callback?: InvokeCallback<T>
) {
  const cbId = callbackId++
  if (callback) {
    callbacks.set(cbId, callback)
  }

  if (globalThis.__NZAppServiceNativeSDK) {
    const msg = {
      event,
      params: JSON.stringify(params),
      callbackId: cbId
    }
    globalThis.__NZAppServiceNativeSDK.messageChannel.invokeHandler.postMessage(msg)
  } else if (globalThis.webkit) {
    const msg = {
      event,
      params: JSON.stringify(params),
      callbackId: cbId
    }
    globalThis.webkit.messageHandlers.invokeHandler.postMessage(msg)
  }
}

export function invokeCallbackHandler(result: InvokeCallbackResult<unknown>) {
  const callback = callbacks.get(result.id)
  if (callback) {
    if (isString(result.data)) {
      try {
        result.data = JSON.parse(result.data)
      } catch (e) {}
    }
    callback(result)
    callbacks.delete(result.id)
  }
}

export type SubscribeCallback<T> = (result: T, webViewId: number) => void

const subscribes = new Map<string, SubscribeCallback<any>>()

export function publish(event: string, params: Record<string, any> = {}, webViewId: number) {
  if (globalThis.__NZAppServiceNativeSDK) {
    globalThis.__NZAppServiceNativeSDK.messageChannel.publishHandler.postMessage({
      event,
      params: JSON.stringify(params),
      webViewId: webViewId
    })
  } else if (globalThis.webkit) {
    globalThis.webkit.messageHandlers.publishHandler.postMessage({
      event,
      params: JSON.stringify(params),
      webViewId: webViewId
    })
  }
}

export function subscribe<T = unknown>(event: string, callback: SubscribeCallback<T>) {
  subscribes.set(event, callback)
}

export function subscribeHandler(event: string, message: any, webViewId: number = 0) {
  const callback = subscribes.get(event)
  if (callback) {
    callback(message, webViewId)
  }
}
