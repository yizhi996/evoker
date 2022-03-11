import {
  AsyncReturn,
  GeneralCallbackResult,
  invokeSuccess,
  wrapperAsyncAPI
} from "../../bridge"

interface SystemSetting {
  bluetoothEnabled: boolean
  locationEnabled: boolean
  wifiEnabled: boolean
  deviceOrientation: "portrait" | "landscape"
}

export function getSystemSetting(): SystemSetting {
  return __NZAppServiceNativeSDK.system.getSystemSetting()
}

interface DeviceInfo {
  brand: string
  model: string
  system: string
  platform: string
}

export function getDeviceInfo(): DeviceInfo {
  return __NZAppServiceNativeSDK.system.getDeviceInfo()
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
  return __NZAppServiceNativeSDK.system.getWindowInfo()
}

interface AppBaseInfo {
  SDKVersion: string
  enableDebug: boolean
  language: string
  version: string
  theme: "light" | "dark"
}

export function getAppBaseInfo(): AppBaseInfo {
  return __NZAppServiceNativeSDK.system.getAppBaseInfo()
}

export function getSystemInfoSync(): SystemSetting &
  DeviceInfo &
  WindowInfo &
  AppBaseInfo {
  return Object.assign(
    {},
    getSystemSetting(),
    getDeviceInfo(),
    getWindowInfo(),
    getAppBaseInfo()
  )
}

interface GetSystemInfoOptions {
  success?: GetSystemInfoSuccessCallback
  fail?: GetSystemInfoFailCallback
  complete?: GetSystemInfoCompleteCallback
}

type GetSystemInfoSuccessCallback = (
  res: SystemSetting & DeviceInfo & WindowInfo & AppBaseInfo
) => void

type GetSystemInfoFailCallback = (res: GeneralCallbackResult) => void

type GetSystemInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getSystemInfoAsync<
  T extends GetSystemInfoOptions = GetSystemInfoOptions
>(options: T): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI<T>(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfoAsync", options, result)
  }, options)
}

export function getSystemInfo<
  T extends GetSystemInfoOptions = GetSystemInfoOptions
>(options: T): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI<T>(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfo", options, result)
  }, options)
}
