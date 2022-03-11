import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  GetNetworkType = "getNetworkType",
  GetLocalIPAddress = "getLocalIPAddress"
}

interface GetNetworkTypeOptions {
  success?: GetNetworkTypeSuccessCallback
  fail?: GetNetworkTypeFailCallback
  complete?: GetNetworkTypeCompleteCallback
}

interface GetNetworkTypeSuccessCallbackResult {
  networkType: "wifi" | "2g" | "3g" | "4g" | "5g" | "unknown" | "none"
}

type GetNetworkTypeSuccessCallback = (
  res: GetNetworkTypeSuccessCallbackResult
) => void

type GetNetworkTypeFailCallback = (res: GeneralCallbackResult) => void

type GetNetworkTypeCompleteCallback = (res: GeneralCallbackResult) => void

export function getNetworkType<
  T extends GetNetworkTypeOptions = GetNetworkTypeOptions
>(options: T): AsyncReturn<T, GetNetworkTypeOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.GetNetworkType, {}, result => {
      invokeCallback(Events.GetNetworkType, options, result)
    })
  }, options)
}

interface GetLocalIPAddressOptions {
  success?: GetLocalIPAddressSuccessCallback
  fail?: GetLocalIPAddressFailCallback
  complete?: GetLocalIPAddressCompleteCallback
}

interface GetLocalIPAddressSuccessCallbackResult {
  localip: string
}

type GetLocalIPAddressSuccessCallback = (
  res: GetLocalIPAddressSuccessCallbackResult
) => void

type GetLocalIPAddressFailCallback = (res: GeneralCallbackResult) => void

type GetLocalIPAddressCompleteCallback = (res: GeneralCallbackResult) => void

export function getLocalIPAddress<
  T extends GetLocalIPAddressOptions = GetLocalIPAddressOptions
>(options: T): AsyncReturn<T, GetLocalIPAddressOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.GetLocalIPAddress, {}, result => {
      invokeCallback(Events.GetLocalIPAddress, options, result)
    })
  }, options)
}
