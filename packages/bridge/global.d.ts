import { DataType, GetStorageInfoSuccessCallbackResult } from "./src/api/storage"
import { DevtoolsBridgeCommands, InvokeArgs, PublishArgs } from "@evoker/shared"
import { InvokeCallbackResult } from "./src"

interface Base64 {
  base64ToArrayBuffer(string: string): ArrayBuffer

  arrayBufferToBase64(buffer: ArrayBuffer): string
}

interface FileSystemGeneralResult {
  errMsg: string
}

interface Stats {
  mode: number
  size: number
  lastAccessedTime: number
  lastModifiedTime: number
}

interface FileSystem {
  access(path: string): FileSystemGeneralResult

  mkdir(dirPath: string, recursive: boolean): FileSystemGeneralResult

  rmdir(dirPath: string, recursive: boolean): FileSystemGeneralResult

  readdir(dirPath: string): FileSystemGeneralResult & { files: string[] }

  readFile(options: any): FileSystemGeneralResult & { data: string | ArrayBuffer }

  writeFile(filePath: string, data: string | ArrayBuffer, encoding: string): FileSystemGeneralResult

  rename(oldPath: string, newPath: string): FileSystemGeneralResult

  copy(srcPath: string, destPath: string): FileSystemGeneralResult

  appendFile(
    filePath: string,
    data: string | ArrayBuffer,
    encoding: string
  ): FileSystemGeneralResult

  unlink(filePath: string): FileSystemGeneralResult

  open(filePath: string, flag: string): FileSystemGeneralResult & { fd: string }

  close(fd: string): FileSystemGeneralResult

  fstat(fd: string): FileSystemGeneralResult & { stats: Stats }

  ftruncate(fd: string, length: number): FileSystemGeneralResult

  read(
    fd: string,
    arrayBuffer: ArrayBuffer,
    offset: number,
    length: number,
    position: number
  ): FileSystemGeneralResult & { bytesRead: number }
}

export interface NativeSDK {
  shareAppMessage(title: string, path: string, imageUrl: string): void

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

interface ArrayBufferRegister {
  get(id: number): ArrayBuffer

  set(arrayBuffer: ArrayBuffer): number
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
  var __NativeSDK: NativeSDK
  var __MessageChannel: MessageChannel
  var __FileSystem: FileSystem
  var __NativeTimer: NativeTimer
  var __System: NativeSystem
  var __Storage: Storage
  var __Base64: Base64
  var __ArrayBufferRegister: ArrayBufferRegister
  var __Config: Config
  var __Devtools: Devtools
  var JSBridge: JSBridge
}

export {}
