import { invoke } from "../../bridge"
import { invokeCallback, GeneralCallbackResult, AsyncReturn, wrapperAsyncAPI } from "../../async"

const enum Events {
  START_PULL_DOWN_REFRESH = "startPullDownRefresh",
  STOP_PULL_DOWN_REFRESH = "stopPullDownRefresh"
}

interface StartPullDownRefreshOptions {
  /** 接口调用成功的回调函数 */
  success?: StartPullDownRefreshSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: StartPullDownRefreshFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: StartPullDownRefreshCompleteCallback
}

type StartPullDownRefreshSuccessCallback = (res: GeneralCallbackResult) => void

type StartPullDownRefreshFailCallback = (res: GeneralCallbackResult) => void

type StartPullDownRefreshCompleteCallback = (res: GeneralCallbackResult) => void

export function startPullDownRefresh<
  T extends StartPullDownRefreshOptions = StartPullDownRefreshOptions
>(options: T): AsyncReturn<T, StartPullDownRefreshOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.START_PULL_DOWN_REFRESH
    invoke(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface StopPullDownRefreshOptions {
  /** 接口调用成功的回调函数 */
  success?: StopPullDownRefreshSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: StopPullDownRefreshFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: StopPullDownRefreshCompleteCallback
}

type StopPullDownRefreshSuccessCallback = (res: GeneralCallbackResult) => void

type StopPullDownRefreshFailCallback = (res: GeneralCallbackResult) => void

type StopPullDownRefreshCompleteCallback = (res: GeneralCallbackResult) => void

export function stopPullDownRefresh<
  T extends StopPullDownRefreshOptions = StopPullDownRefreshOptions
>(options: T): AsyncReturn<T, StopPullDownRefreshOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.STOP_PULL_DOWN_REFRESH
    invoke(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
