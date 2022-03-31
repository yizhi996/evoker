import { invoke, subscribe } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { onEvent, offEvent, emitEvent } from "../../event"

const enum Events {
  GET_NETWORK_TYPE = "getNetworkType",
  GET_LOCAL_IP_ADDRESS = "getLocalIPAddress",
  ON_NETWORK_STATUS_CHANGE = "APP_NETWORK_STATUS_CHANGE"
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
    invoke<SuccessResult<T>>(Events.GET_NETWORK_TYPE, {}, result => {
      invokeCallback(Events.GET_NETWORK_TYPE, options, result)
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

subscribe<OnNetworkStatusChangeCallbackResult>(
  Events.ON_NETWORK_STATUS_CHANGE,
  result => {
    emitEvent(Events.ON_NETWORK_STATUS_CHANGE, result)
  }
)

export function onNetworkStatusChange(callback: OnNetworkStatusChangeCallback) {
  onEvent(Events.ON_NETWORK_STATUS_CHANGE, callback)
}

export function offNetworkStatusChange(callback: () => void) {
  offEvent(Events.ON_NETWORK_STATUS_CHANGE, callback)
}
