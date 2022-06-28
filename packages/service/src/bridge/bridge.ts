import { invoke, invokeCallbackHandler, publish, subscribe, subscribeHandler } from "@evoker/bridge"

export const InnerJSBridge = {
  invoke,
  publish,
  subscribe,
  invokeCallbackHandler,
  subscribeHandler
}

const JSBridge = {
  get invokeCallbackHandler() {
    return invokeCallbackHandler
  },
  get subscribeHandler() {
    return subscribeHandler
  }
}
;(globalThis as any).JSBridge = JSBridge
