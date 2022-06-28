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
  success?: GetUserInfoSuccessCallback
  fail?: GetUserInfoFailCallback
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
