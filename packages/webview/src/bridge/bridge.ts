import {
  invoke,
  invokeCallbackHandler,
  publish,
  subscribe,
  subscribeHandler
} from "@nzoth/bridge"

const NZJSBridge = {
  invoke: invoke,
  publish: publish,
  subscribe: subscribe,
  invokeCallbackHandler: invokeCallbackHandler,
  subscribeHandler: subscribeHandler
}
;(globalThis as any).NZJSBridge = NZJSBridge

export default NZJSBridge