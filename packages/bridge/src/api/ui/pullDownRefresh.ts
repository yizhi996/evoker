import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  StartPullDownRefresh = "startPullDownRefresh",
  StopPullDownRefresh = "stopPullDownRefresh"
}

interface StartPullDownRefreshOptions {
  success?: StartPullDownRefreshSuccessCallback
  fail?: StartPullDownRefreshFailCallback
  complete?: StartPullDownRefreshCompleteCallback
}

type StartPullDownRefreshSuccessCallback = (res: GeneralCallbackResult) => void

type StartPullDownRefreshFailCallback = (res: GeneralCallbackResult) => void

type StartPullDownRefreshCompleteCallback = (res: GeneralCallbackResult) => void

export function startPullDownRefresh<
  T extends StartPullDownRefreshOptions = StartPullDownRefreshOptions
>(options: T): AsyncReturn<T, StartPullDownRefreshOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke(Events.StartPullDownRefresh, {}, result => {
      invokeCallback(Events.StartPullDownRefresh, options, result)
    })
  }, options)
}

interface StopPullDownRefreshOptions {
  success?: StopPullDownRefreshSuccessCallback
  fail?: StopPullDownRefreshFailCallback
  complete?: StopPullDownRefreshCompleteCallback
}

type StopPullDownRefreshSuccessCallback = (res: GeneralCallbackResult) => void

type StopPullDownRefreshFailCallback = (res: GeneralCallbackResult) => void

type StopPullDownRefreshCompleteCallback = (res: GeneralCallbackResult) => void

export function stopPullDownRefresh<
  T extends StopPullDownRefreshOptions = StopPullDownRefreshOptions
>(options: T): AsyncReturn<T, StopPullDownRefreshOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke(Events.StopPullDownRefresh, {}, result => {
      invokeCallback(Events.StopPullDownRefresh, options, result)
    })
  }, options)
}
