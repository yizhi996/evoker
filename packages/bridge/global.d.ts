import { DataType, GetStorageInfoSuccessCallbackResult } from "./src/api/storage"

interface Base64 {
  base64ToArrayBuffer(string: string): number[]

  arrayBufferToBase64(buffer: ArrayBuffer): string
}

interface NZAppServiceNativeSDK {
  timer: NativeTimer

  messageChannel: MessageChannel

  system: NativeSystem

  storage: Storage

  base64: Base64
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
  messageHandlers: MessageChannel
}

interface SystemSetting {
  bluetoothEnabled: boolean
  locationEnabled: boolean
  wifiEnabled: boolean
  deviceOrientation: "portrait" | "landscape"
}

interface DeviceInfo {
  brand: string
  model: string
  system: string
  platform: string
}

interface WindowInfo {
  pixelRatio: number
  screenWidth: number
  screenHeight: number
  windowWidth: number
  windowHeight: number
  statusBarHeight: number
  safeArea: SafeArea
  screenTop: number
}

interface SafeArea {
  left: number
  right: number
  top: number
  bottom: number
  width: number
  height: number
}

interface AppBaseInfo {
  SDKVersion: string
  enableDebug: boolean
  language: string
  version: string
  theme: "light" | "dark"
}

type AuthorizedStatus = "authorized" | "denied" | "not determined"

interface AppAuthorizedSetting {
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

interface NZConfig {
  appId: string
  appName: string
  appIcon: string
  pages: Page[]
  tabBar?: TabBar
}

declare global {
  var webkit: WebKit
  var __NZAppServiceNativeSDK: NZAppServiceNativeSDK
  var __NZConfig: NZConfig
}

export {}
