import {
  GeneralCallbackResult,
  AsyncReturn,
  wrapperAsyncAPI,
  SuccessResult,
  invokeCallback,
  invokeFailure
} from "evoker"
import { isString } from "@vue/shared"
import { App, EnvVersion, useLocalStore } from "../storage"
import { isEqualApp, parseURL } from "../utils"

const launcherAppId = "com.evokerdev.launcher"

const enum Events {
  OPEN_APP = "openApp",
  UPDATE_APP = "updateApp",
  DELETE_APP = "deleteApp",
  IS_RUNNING = "isRunning",
  GET_APP_VERSION = "getAppVersion",
  CONNECT_DEV_SERVER = "connectDevServer",
  DISCONNECT_DEV_SERVER = "disconnectDevServer"
}

interface OpenAppOptions {
  appId: string
  envVersion: EnvVersion
  /** 接口调用成功的回调函数 */
  success?: OpenAppSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: OpenAppFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: OpenAppCompleteCallback
}

type OpenAppSuccessCallback = (res: GeneralCallbackResult) => void

type OpenAppFailCallback = (res: GeneralCallbackResult) => void

type OpenAppCompleteCallback = (res: GeneralCallbackResult) => void

export function openApp<T extends OpenAppOptions = OpenAppOptions>(
  options: T
): AsyncReturn<T, OpenAppOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.OPEN_APP

    if (options.appId === launcherAppId) {
      invokeFailure(event, options, "cannot operate launcher.")
      return
    }
    console.log("open")
    JSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface UpdateAppOptions {
  appId: string
  envVersion: EnvVersion
  version: string
  filePath: string
  /** 接口调用成功的回调函数 */
  success?: UpdateAppSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: UpdateAppFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: UpdateAppCompleteCallback
}

type UpdateAppSuccessCallback = (res: GeneralCallbackResult) => void

type UpdateAppFailCallback = (res: GeneralCallbackResult) => void

type UpdateAppCompleteCallback = (res: GeneralCallbackResult) => void

export function updateApp<T extends UpdateAppOptions = UpdateAppOptions>(
  options: T
): AsyncReturn<T, UpdateAppOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.UPDATE_APP

    if (options.appId === launcherAppId) {
      invokeFailure(event, options, "cannot operate launcher.")
      return
    }

    JSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface DeleteAppOptions {
  appId: string
  envVersion: EnvVersion
  /** 接口调用成功的回调函数 */
  success?: DeleteAppSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: DeleteAppFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: DeleteAppCompleteCallback
}

type DeleteAppSuccessCallback = (res: GeneralCallbackResult) => void

type DeleteAppFailCallback = (res: GeneralCallbackResult) => void

type DeleteAppCompleteCallback = (res: GeneralCallbackResult) => void

export function deleteApp<T extends DeleteAppOptions = DeleteAppOptions>(
  options: T
): AsyncReturn<T, DeleteAppOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.DELETE_APP

    if (options.appId === launcherAppId) {
      invokeFailure(event, options, "cannot operate launcher.")
      return
    }

    JSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface IsRunningOptions {
  appId: string
  envVersion: EnvVersion
  /** 接口调用成功的回调函数 */
  success?: IsRunningSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: IsRunningFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: IsRunningCompleteCallback
}

interface IsRunningSuccessCallbackResult {
  running: boolean
}

type IsRunningSuccessCallback = (res: IsRunningSuccessCallbackResult) => void

type IsRunningFailCallback = (res: GeneralCallbackResult) => void

type IsRunningCompleteCallback = (res: GeneralCallbackResult) => void

export function isRunning<T extends IsRunningOptions = IsRunningOptions>(
  options: T
): AsyncReturn<T, IsRunningOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.IS_RUNNING

    if (options.appId === launcherAppId) {
      invokeFailure(event, options, "cannot operate launcher.")
      return
    }

    JSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetAppVersionOptions {
  appId: string
  envVersion: EnvVersion
  /** 接口调用成功的回调函数 */
  success?: GetAppVersionSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetAppVersionFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetAppVersionCompleteCallback
}

interface GetAppVersionSuccessCallbackResult {
  version: string
}

type GetAppVersionSuccessCallback = (res: GetAppVersionSuccessCallbackResult) => void

type GetAppVersionFailCallback = (res: GeneralCallbackResult) => void

type GetAppVersionCompleteCallback = (res: GeneralCallbackResult) => void

export function getAppVersion<T extends GetAppVersionOptions = GetAppVersionOptions>(
  options: T
): AsyncReturn<T, GetAppVersionOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_APP_VERSION

    if (options.appId === launcherAppId) {
      invokeFailure(event, options, "cannot operate launcher.")
      return
    }

    JSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface ConnectDevServerOptions {
  /** ws address */
  url: string
  /** 接口调用成功的回调函数 */
  success?: ConnectDevServerSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ConnectDevServerFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ConnectDevServerCompleteCallback
}

type ConnectDevServerSuccessCallback = (res: GeneralCallbackResult) => void

type ConnectDevServerFailCallback = (res: GeneralCallbackResult) => void

type ConnectDevServerCompleteCallback = (res: GeneralCallbackResult) => void

export function connectDevServer<T extends ConnectDevServerOptions = ConnectDevServerOptions>(
  options: T
): AsyncReturn<T, ConnectDevServerOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.CONNECT_DEV_SERVER
    if (!isString(options.url)) {
      invokeFailure(event, options, "options.url cannot be empty")
      return
    }

    const url = parseURL(options.url)
    JSBridge.invoke<SuccessResult<T>>(
      event,
      { url: options.url, host: url.hostname, port: parseInt(url.port) },
      result => {
        invokeCallback(event, options, result)
      }
    )
  }, options)
}

interface DisconnectDevServerOptions {
  /** ws address */
  url: string
  /** 接口调用成功的回调函数 */
  success?: DisconnectDevServerSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: DisconnectDevServerFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: DisconnectDevServerCompleteCallback
}

type DisconnectDevServerSuccessCallback = (res: GeneralCallbackResult) => void

type DisconnectDevServerFailCallback = (res: GeneralCallbackResult) => void

type DisconnectDevServerCompleteCallback = (res: GeneralCallbackResult) => void

export function disconnectDevServer<
  T extends DisconnectDevServerOptions = DisconnectDevServerOptions
>(options: T): AsyncReturn<T, DisconnectDevServerOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.DISCONNECT_DEV_SERVER
    if (!isString(options.url)) {
      invokeFailure(event, options, "options.url cannot be empty")
      return
    }

    JSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

const enum SubscribeKeys {
  SET_APP_INFO = "LAUNCHER_DEV_SERVER_SET_APP_INFO",
  UPDATE_APP_VERSION = "LAUNCHER_DEV_SERVER_UPDATE_APP_VERSION"
}

JSBridge.subscribe<App>(SubscribeKeys.SET_APP_INFO, message => {
  if (message.appId === launcherAppId) {
    return
  }

  const storage = useLocalStore()
  const i = storage.apps.findIndex(app => isEqualApp(app, message))
  if (i > -1) {
    storage.apps[i] = message
  } else {
    storage.apps.push(message)
  }
  storage.saveLocalApps()
})

interface UpdateData {
  appId: string
  envVersion: EnvVersion
  version: string
}

JSBridge.subscribe<UpdateData>(SubscribeKeys.UPDATE_APP_VERSION, message => {
  if (message.appId === launcherAppId) {
    return
  }

  const storage = useLocalStore()
  const i = storage.apps.findIndex(app => isEqualApp(app, message))
  if (i > -1) {
    storage.apps[i].version = message.version
    storage.saveLocalApps()
  }
})
