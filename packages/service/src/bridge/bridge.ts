import {
  invoke,
  invokeCallbackHandler,
  publish,
  subscribe,
  subscribeHandler
} from "@nzoth/bridge"

export const InnerJSBridge = {
  invoke,
  publish,
  subscribe,
  invokeCallbackHandler,
  subscribeHandler
}

const NZJSBridge = {
  get invokeCallbackHandler() {
    return invokeCallbackHandler
  },
  get subscribeHandler() {
    return subscribeHandler
  }
}
;(globalThis as any).NZJSBridge = NZJSBridge
