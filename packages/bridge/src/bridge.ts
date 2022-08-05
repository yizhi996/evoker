import { isString } from "@vue/shared"
import { DevtoolsBridgeCommands, isDevtools } from "@evoker/shared"

const isService = globalThis.__Config.env === "service"

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

  const msg = {
    event,
    params: JSON.stringify(params),
    callbackId: cbId
  }

  if (isDevtools) {
    const command = isService
      ? DevtoolsBridgeCommands.APP_SERVICE_INVOKE
      : DevtoolsBridgeCommands.WEB_VIEW_INVOKE
    __Devtools.invokeHandler(command, msg)
  } else {
    if (globalThis.__AppServiceNativeSDK) {
      globalThis.__AppServiceNativeSDK.messageChannel.invokeHandler.postMessage(msg)
    } else if (globalThis.webkit) {
      globalThis.webkit.messageHandlers.invokeHandler.postMessage(msg)
    }
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
  const msg = {
    event,
    params: JSON.stringify(params),
    webViewId: webViewId
  }
  if (isDevtools) {
    const command = isService
      ? DevtoolsBridgeCommands.APP_SERVICE_PUBLISH
      : DevtoolsBridgeCommands.WEB_VIEW_PUBLISH
    __Devtools.publishHandler(command, msg)
  } else {
    if (globalThis.__AppServiceNativeSDK) {
      globalThis.__AppServiceNativeSDK.messageChannel.publishHandler.postMessage(msg)
    } else if (globalThis.webkit) {
      globalThis.webkit.messageHandlers.publishHandler.postMessage(msg)
    }
  }
}

export function subscribe<T = unknown>(event: string, callback: SubscribeCallback<T>) {
  subscribes.set(event, callback)
}

export function subscribeHandler(event: string, message: any, webViewId: number = 0) {
  const callback = subscribes.get(event)
  callback && callback(message, webViewId)
}
