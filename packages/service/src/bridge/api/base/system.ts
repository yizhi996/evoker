import { AsyncReturn, GeneralCallbackResult, invokeSuccess, wrapperAsyncAPI } from "@nzoth/bridge"
import { extend } from "@nzoth/shared"

export function getSystemSetting() {
  return globalThis.__NZAppServiceNativeSDK.system.getSystemSetting()
}

export function getDeviceInfo() {
  return globalThis.__NZAppServiceNativeSDK.system.getDeviceInfo()
}

export function getWindowInfo() {
  return globalThis.__NZAppServiceNativeSDK.system.getWindowInfo()
}

export function getAppBaseInfo() {
  return globalThis.__NZAppServiceNativeSDK.system.getAppBaseInfo()
}

export function getAppAuthorizeSetting() {
  return globalThis.__NZAppServiceNativeSDK.system.getAppAuthorizeSetting()
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
  return wrapperAsyncAPI<T>(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfoAsync", options, result)
  }, options)
}

export function getSystemInfo<T extends GetSystemInfoOptions = GetSystemInfoOptions>(
  options: T
): AsyncReturn<T, GetSystemInfoOptions> {
  return wrapperAsyncAPI<T>(options => {
    const result = getSystemInfoSync()
    invokeSuccess("getSystemInfo", options, result)
  }, options)
}
