import {
  invoke,
  invokeCallbackHandler,
  publish,
  subscribe,
  subscribeHandler
} from "@nzoth/bridge"

export const InnerJSBridge = {
  invoke: invoke,
  publish: publish,
  subscribe: subscribe,
  invokeCallbackHandler: invokeCallbackHandler,
  subscribeHandler: subscribeHandler
}

const NZJSBridge = {
  invokeCallbackHandler: invokeCallbackHandler,
  subscribeHandler: subscribeHandler
}
;(globalThis as any).NZJSBridge = NZJSBridge
