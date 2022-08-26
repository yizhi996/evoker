import { AsyncReturn, GeneralCallbackResult, invokeSuccess, wrapperAsyncAPI } from "@evoker/bridge"
import { extend } from "@vue/shared"

interface SystemSetting {
  bluetoothEnabled: boolean
  locationEnabled: boolean
  wifiEnabled: boolean
  deviceOrientation: "portrait" | "landscape"
}

export function getSystemSetting(): SystemSetting {
  return globalThis.__System.getSystemSetting()
}

interface DeviceInfo {
  brand: string
  model: string
  system: string
  platform: string
}

export function getDeviceInfo(): DeviceInfo {
  return globalThis.__System.getDeviceInfo()
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

export function getWindowInfo(): WindowInfo {
  return globalThis.__System.getWindowInfo()
}

interface AppBaseInfo {
  SDKVersion: string
  enableDebug: boolean
  language: string
  version: string
  theme: "light" | "dark"
}

export function getAppBaseInfo(): AppBaseInfo {
  return globalThis.__System.getAppBaseInfo()
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

export function getAppAuthorizeSetting(): AppAuthorizedSetting {
  return globalThis.__System.getAppAuthorizeSetting()
}

export function getSystemInfoSync() {
  return extend(
    getSystemSetting(),
    getDeviceInfo(),
    getWindowInfo(),
    getAppBaseInfo(),
    getAppAuthorizeSetting()
  )
}

interface GetSystemInfoOptions {
  success?: GetSystemInfoSuccessCallback
  fail?: GetSystemInfoFailCallback
  complete?: GetSystemInfoCompleteCallback
}

type GetSystemInfoSuccessCallback = (res: ReturnType<typeof getSystemInfoSync>) => void

type GetSystemInfoFailCallback = (res: GeneralCallbackResult) => void

type GetSystemInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getSystemInfoAsync<T extends GetSystemInfoOptions = GetSystemInfoOptions>(
  options: T
): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfoAsync", options, result)
  }, options)
}

export function getSystemInfo<T extends GetSystemInfoOptions = GetSystemInfoOptions>(
  options: T
): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfo", options, result)
  }, options)
}
