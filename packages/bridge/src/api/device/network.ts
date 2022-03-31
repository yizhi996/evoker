import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { on, off } from "../../event"

const enum Events {
  GET_NETWORK_TYOE = "getNetworkType",
  GET_LOCAL_IP_ADDRESS = "getLocalIPAddress"
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
    invoke<SuccessResult<T>>(Events.GET_NETWORK_TYOE, {}, result => {
      invokeCallback(Events.GET_NETWORK_TYOE, options, result)
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
    invoke<SuccessResult<T>>(Events.GET_LOCAL_IP_ADDRESS, {}, result => {
      invokeCallback(Events.GET_LOCAL_IP_ADDRESS, options, result)
    })
  }, options)
}

interface OnNetworkStatusChangeCallbackResult {
  isConnected: boolean
  networkType: "wifi" | "2g" | "3g" | "4g" | "5g" | "unknown" | "none"
}

type OnNetworkStatusChangeCallback = (
  result: OnNetworkStatusChangeCallbackResult
) => void

export function onNetworkStatusChange(callback: OnNetworkStatusChangeCallback) {
  on("networkStatusChange", callback)
}

export function offNetworkStatusChange(callback: () => void) {
  off("networkStatusChange", callback)
}
