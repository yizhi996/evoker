import {
  invoke,
  invokeCallbackHandler,
  publish,
  subscribe,
  subscribeHandler
} from "@nzoth/bridge"

const NZJSBridge = {
  invoke,
  publish,
  subscribe,
  invokeCallbackHandler,
  subscribeHandler
}
;(globalThis as any).NZJSBridge = NZJSBridge

export default NZJSBridge
