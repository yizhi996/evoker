export const enum DevtoolsBridgeCommands {
  APP_SERVICE_INVOKE = "APP_SERVICE_INVOKE",
  APP_SERVICE_PUBLISH = "APP_SERVICE_PUBLISH",
  WEB_VIEW_INVOKE = "WEB_VIEW_INVOKE",
  WEB_VIEW_PUBLISH = "WEB_VIEW_PUBLISH"
}

export const enum DevtoolsBridgeExecEvents {
  INVOKE_CALLBACK = "INVOKE_CALLBACK",
  SUBSCRIBE_HANDLER = "SUBSCRIBE_HANDLER"
}

export interface InvokeArgs {
  event: string
  params: string
  callbackId: number
}

export interface PublishArgs {
  event: string
  params: string
  webViewId: number
}
