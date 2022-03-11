import { InnerJSBridge } from "./bridge"

import {
  navigateTo,
  navigateBack,
  redirectTo,
  reLaunch,
  switchTab
} from "./api/route"

const invokeWebViewMethods: Record<string, Function> = {
  navigateTo,
  redirectTo,
  switchTab,
  reLaunch,
  navigateBack
}

InnerJSBridge.subscribe("invokeAppServiceMethod", (message, webViewId) => {
  const callbackId = message.callbackId
  const fn = invokeWebViewMethods[message.event]
  if (fn) {
    const options = message.params
    fn.call(null, options).then((message: any) => {
      InnerJSBridge.publish(
        "callbackAppServiceMethod",
        {
          message,
          callbackId
        },
        webViewId
      )
    })
  }
})
