import JSBridge from "../bridge"

import {
  invokeCallback,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  requestAuthorization
} from "@evoker/bridge"

const enum Events {
  GET_USER_INFO = "getUserInfo"
}

interface GetUserInfoOptions {
  withCredentials?: boolean
  lang?: "en" | "zh_CN" | "zh_TW"
  /** 接口调用成功的回调函数 */
  success?: GetUserInfoSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetUserInfoFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetUserInfoCompleteCallback
}

type GetUserInfoSuccessCallback = (res: GeneralCallbackResult) => void

type GetUserInfoFailCallback = (res: GeneralCallbackResult) => void

type GetUserInfoCompleteCallback = (res: GeneralCallbackResult) => void

export function getUserInfo<T extends GetUserInfoOptions = GetUserInfoOptions>(
  options: T
): AsyncReturn<T, GetUserInfoOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.GET_USER_INFO
      const scope = "scope.userInfo"
      requestAuthorization(scope, false)
        .then(() => {
          JSBridge.invoke<SuccessResult<T>>(event, options, result => {
            invokeCallback(event, options, result)
          })
        })
        .catch(err => {
          invokeFailure(event, options, err)
        })
    },
    options,
    { withCredentials: false, lang: "en" }
  )
}
