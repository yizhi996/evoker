import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  wrapperAsyncAPI
} from "../../bridge"

const enum Events {
  START_PULL_DOWN_REFRESH = "startPullDownRefresh",
  STOP_PULL_DOWN_REFRESH = "stopPullDownRefresh"
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
    invoke(Events.START_PULL_DOWN_REFRESH, {}, result => {
      invokeCallback(Events.START_PULL_DOWN_REFRESH, options, result)
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
    invoke(Events.STOP_PULL_DOWN_REFRESH, {}, result => {
      invokeCallback(Events.STOP_PULL_DOWN_REFRESH, options, result)
    })
  }, options)
}
