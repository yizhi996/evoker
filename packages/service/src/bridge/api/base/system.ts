import { AsyncReturn, GeneralCallbackResult, invokeSuccess, wrapperAsyncAPI } from "@evoker/bridge"
import { extend } from "@vue/shared"

interface SystemSetting {
  /** 蓝牙的系统开关 */
  bluetoothEnabled: boolean
  /** 地理位置的系统开关 */
  locationEnabled: boolean
  /** Wi-Fi 的系统开关 */
  wifiEnabled: boolean
  /** 设备方向
   *
   * 合法值：
   * - portrait: 竖屏
   * - landscape: 横屏
   */
  deviceOrientation: "portrait" | "landscape"
}

/** 获取设备设置 */
export function getSystemSetting(): SystemSetting {
  return globalThis.__System.getSystemSetting()
}

interface DeviceInfo {
  /** 设备品牌 */
  brand: string
  /** 设备型号 */
  model: string
  /** 操作系统及版本 */
  system: string
  /** 客户端平台 */
  platform: string
}

/** 获取设备基础信息 */
export function getDeviceInfo(): DeviceInfo {
  return globalThis.__System.getDeviceInfo()
}

interface WindowInfo {
  /** 设备像素比 */
  pixelRatio: number
  /** 屏幕宽度，单位px */
  screenWidth: number
  /** 屏幕高度，单位px */
  screenHeight: number
  /** 可使用窗口宽度，单位px */
  windowWidth: number
  /** 可使用窗口高度，单位px */
  windowHeight: number
  /** 状态栏的高度，单位px */
  statusBarHeight: number
  /** 安全区域 */
  safeArea: SafeArea
  /** 窗口上边缘的 y 值，单位px */
  screenTop: number
}

interface SafeArea {
  /** 安全区域左上角横坐标 */
  left: number
  /** 安全区域右下角横坐标 */
  right: number
  /** 安全区域左上角纵坐标 */
  top: number
  /** 安全区域右下角纵坐标 */
  bottom: number
  /** 安全区域的宽度 */
  width: number
  /** 安全区域的高度 */
  height: number
}

/** 获取窗口信息 */
export function getWindowInfo(): WindowInfo {
  return globalThis.__System.getWindowInfo()
}

interface AppBaseInfo {
  /** 客户端JS基础库版本 */
  SDKVersion: string
  /** 原生客户端基础库版本 */
  nativeSDKVersion: string
  /** 系统语言 */
  language: string
  /** 宿主版本号 */
  version: string
  /** 系统当前主题 */
  theme: "light" | "dark"
}

/** 获取宿主 APP 基础信息 */
export function getAppBaseInfo(): AppBaseInfo {
  return globalThis.__System.getAppBaseInfo()
}

type AuthorizedStatus = "authorized" | "denied" | "not determined"

interface AppAuthorizedSetting {
  /** 允许宿主使用相册的开关 */
  albumAuthorized: AuthorizedStatus
  /** 允许宿主使用蓝牙的开关 */
  bluetoothAuthorized: AuthorizedStatus
  /** 允许宿主使用摄像头的开关 */
  cameraAuthorized: AuthorizedStatus
  /** 允许宿主使用定位的开关 */
  locationAuthorized: AuthorizedStatus
  /** 是否是模糊定位 */
  locationReducedAccuracy: boolean
  /** 允许宿主使用麦克风的开关 */
  microphoneAuthorized: AuthorizedStatus
  /** 允许宿主通知的开关 */
  notificationAuthorized: AuthorizedStatus
  /** 允许宿主通知带有提醒的开关 */
  notificationAlertAuthorized: AuthorizedStatus
  /** 允许宿主通知带有标记的开关 */
  notificationBadgeAuthorized: AuthorizedStatus
  /** 允许宿主通知带有声音的开关 */
  notificationSoundAuthorized: AuthorizedStatus
}

/** 获取宿主 APP 授权设置 */
export function getAppAuthorizeSetting(): AppAuthorizedSetting {
  return globalThis.__System.getAppAuthorizeSetting()
}

/** 获取系统信息 */
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
  /** 接口调用成功的回调函数 */
  success?: GetSystemInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetSystemInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetSystemInfoCompleteCallback
}

type GetSystemInfoSuccessCallback = (res: ReturnType<typeof getSystemInfoSync>) => void

type GetSystemInfoFailCallback = (res: GeneralCallbackResult) => void

type GetSystemInfoCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取系统信息 */
export function getSystemInfoAsync<T extends GetSystemInfoOptions = GetSystemInfoOptions>(
  options: T
): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfoAsync", options, result)
  }, options)
}

/** 获取系统信息 */
export function getSystemInfo<T extends GetSystemInfoOptions = GetSystemInfoOptions>(
  options: T
): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfo", options, result)
  }, options)
}
