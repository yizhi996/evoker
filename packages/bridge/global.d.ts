import { DataType, GetStorageInfoSuccessCallbackResult } from "./src/api/storage"
import { DevtoolsBridgeCommands, InvokeArgs, PublishArgs } from "@evoker/shared"
import { InvokeCallbackResult } from "./src"

interface Base64 {
  base64ToArrayBuffer(string: string): number[]

  arrayBufferToBase64(buffer: ArrayBuffer): string
}

export interface AppServiceNativeSDK {
  timer: NativeTimer

  messageChannel: MessageChannel

  system: NativeSystem

  storage: Storage

  base64: Base64

  evalWebView(script: string, webviewId: number): any
}

interface NativeTimer {
  setTimeout(callback: (args: void) => void, ms?: number): NodeJS.Timeout

  clearTimeout(timeoutId: NodeJS.Timeout): void

  setInterval(callback: (args: void) => void, ms?: number): NodeJS.Timer

  clearInterval(intervalId: NodeJS.Timeout): void
}

interface MessageChannel {
  publishHandler: MessageChannelPort
  invokeHandler: MessageChannelPort
}

interface MessageChannelPort {
  postMessage(message: any): void
}

interface WebKit {
  messageHandlers: MessageChannel & { loaded: MessageChannelPort }
}

export interface SystemSetting {
  bluetoothEnabled: boolean
  locationEnabled: boolean
  wifiEnabled: boolean
  deviceOrientation: "portrait" | "landscape"
}

export interface DeviceInfo {
  brand: string
  model: string
  system: string
  platform: string
}

export interface WindowInfo {
  pixelRatio: number
  screenWidth: number
  screenHeight: number
  windowWidth: number
  windowHeight: number
  statusBarHeight: number
  safeArea: SafeArea
  screenTop: number
}

export interface SafeArea {
  left: number
  right: number
  top: number
  bottom: number
  width: number
  height: number
}

export interface AppBaseInfo {
  SDKVersion: string
  enableDebug: boolean
  language: string
  version: string
  theme: "light" | "dark"
}

type AuthorizedStatus = "authorized" | "denied" | "not determined"

export interface AppAuthorizedSetting {
  albumAuthorized: AuthorizedStatus
  bluetoothAuthorized: AuthorizedStatus
  cameraAuthorized: AuthorizedStatus
  locationAuthorized: AuthorizedStatus
  locationReducedAccuracy: boolean
  microphoneAuthorized: AuthorizedStatus
  notificationAuthorized: AuthorizedStatus
  notificationAlertAuthorized: AuthorizedStatus
  notificationBadgeAuthorized: AuthorizedStatus
  notificationSoundAuthorized: AuthorizedStatus
}

interface NativeSystem {
  getSystemSetting(): SystemSetting

  getDeviceInfo(): DeviceInfo

  getWindowInfo(): WindowInfo

  getAppBaseInfo(): AppBaseInfo

  getAppAuthorizeSetting(): AppAuthorizedSetting
}

interface GetStorageSyncResult {
  data: string
  dataType: DataType
}

interface Storage {
  getStorageSync(key: string): { errMsg: string; result: GetStorageSyncResult }

  setStorageSync(key: string, data: string, dataType: DataType): { errMsg: string }

  getStorageInfoSync(): { errMsg: string; result: GetStorageInfoSuccessCallbackResult }

  removeStorageSync(key: string): { errMsg: string }

  clearStorageSync(): { errMsg: string }
}

interface Page {
  component: string
  path: string
}

interface TabBar {
  list: TabBarItem[]
}

interface TabBarItem {
  path: string
}

interface Config {
  env: "webview" | "service"
  platform: "iOS" | "devtools"
  appId: string
  appName: string
  appIcon: string
  pages: Page[]
  tabBar?: TabBar
  webViewId: number
}

interface Devtools {
  invokeHandler(command: DevtoolsBridgeCommands, args: InvokeArgs)

  publishHandler(command: DevtoolsBridgeCommands, args: PublishArgs)
}

interface JSBridge {
  invokeCallbackHandler: (result: InvokeCallbackResult) => void
  subscribeHandler: (event: string, message: any, webViewId: number) => void
}

declare global {
  var webkit: WebKit
  var __AppServiceNativeSDK: AppServiceNativeSDK
  var __Config: Config
  var __Devtools: Devtools
  var JSBridge: JSBridge
}

export {}
