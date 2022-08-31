import { invoke, subscribe } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"
import { addEvent, removeEvent, dispatchEvent } from "@evoker/shared"

const enum Events {
  GET_NETWORK_TYPE = "getNetworkType",
  GET_LOCAL_IP_ADDRESS = "getLocalIPAddress",
  ON_NETWORK_STATUS_CHANGE = "APP_NETWORK_STATUS_CHANGE"
}

interface GetNetworkTypeOptions {
  /** 接口调用成功的回调函数 */
  success?: GetNetworkTypeSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetNetworkTypeFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetNetworkTypeCompleteCallback
}

interface GetNetworkTypeSuccessCallbackResult {
  /** 网络类型 */
  networkType: "wifi" | "2g" | "3g" | "4g" | "5g" | "unknown" | "none"
}

type GetNetworkTypeSuccessCallback = (res: GetNetworkTypeSuccessCallbackResult) => void

type GetNetworkTypeFailCallback = (res: GeneralCallbackResult) => void

type GetNetworkTypeCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取当前的网络类型 */
export function getNetworkType<T extends GetNetworkTypeOptions = GetNetworkTypeOptions>(
  options: T
): AsyncReturn<T, GetNetworkTypeOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_NETWORK_TYPE
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetLocalIPAddressOptions {
  /** 接口调用成功的回调函数 */
  success?: GetLocalIPAddressSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetLocalIPAddressFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetLocalIPAddressCompleteCallback
}

interface GetLocalIPAddressSuccessCallbackResult {
  localip: string
}

type GetLocalIPAddressSuccessCallback = (res: GetLocalIPAddressSuccessCallbackResult) => void

type GetLocalIPAddressFailCallback = (res: GeneralCallbackResult) => void

type GetLocalIPAddressCompleteCallback = (res: GeneralCallbackResult) => void

export function getLocalIPAddress<T extends GetLocalIPAddressOptions = GetLocalIPAddressOptions>(
  options: T
): AsyncReturn<T, GetLocalIPAddressOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_LOCAL_IP_ADDRESS
    invoke<SuccessResult<T>>(event, {}, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface OnNetworkStatusChangeCallbackResult {
  isConnected: boolean
  networkType: "wifi" | "2g" | "3g" | "4g" | "5g" | "unknown" | "none"
}

type OnNetworkStatusChangeCallback = (result: OnNetworkStatusChangeCallbackResult) => void

subscribe<OnNetworkStatusChangeCallbackResult>(Events.ON_NETWORK_STATUS_CHANGE, result => {
  dispatchEvent(Events.ON_NETWORK_STATUS_CHANGE, result)
})

export function onNetworkStatusChange(callback: OnNetworkStatusChangeCallback) {
  addEvent(Events.ON_NETWORK_STATUS_CHANGE, callback)
}

export function offNetworkStatusChange(callback: () => void) {
  removeEvent(Events.ON_NETWORK_STATUS_CHANGE, callback)
}
