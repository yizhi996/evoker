import { invoke, invokeCallbackHandler, publish, subscribe, subscribeHandler } from "@evoker/bridge"

const JSBridge = {
  invoke,
  publish,
  subscribe,
  invokeCallbackHandler,
  subscribeHandler
}
;(globalThis as any).JSBridge = JSBridge

export default JSBridge
