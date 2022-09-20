import { invoke, invokeCallbackHandler, publish, subscribe, subscribeHandler } from "@evoker/bridge"

export const InnerJSBridge = {
  invoke,
  publish,
  subscribe,
  invokeCallbackHandler,
  subscribeHandler
}

const JSBridge = {
  get invoke() {
    return invoke
  },
  get subscribe() {
    return subscribe
  },
  get invokeCallbackHandler() {
    return invokeCallbackHandler
  },
  get subscribeHandler() {
    return subscribeHandler
  }
}

globalThis.JSBridge = JSBridge
