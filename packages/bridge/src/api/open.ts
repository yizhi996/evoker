import { invoke } from "../bridge"
import {
  invokeCallback,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../async"
import {
  AuthorizationStatus,
  getAuthorize,
  setAuthorize,
  openAuthorizationView
} from "./auth"

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
  return wrapperAsyncAPI<T>(async options => {
    const scope = "scope.userInfo"

    const _getUserInfo = () => {
      invoke<SuccessResult<T>>(
        Events.GET_USER_INFO,
        Object.assign({ withCredentials: false, lang: "en" }, options),
        result => {
          invokeCallback(Events.GET_USER_INFO, options, result)
        }
      )
    }

    try {
      const status = await getAuthorize(scope)
      if (status === AuthorizationStatus.authorized) {
        _getUserInfo()
      } else {
        const authorized = await openAuthorizationView(scope)
        if (authorized) {
          _getUserInfo()
        } else {
          invokeFailure(Events.GET_USER_INFO, options, "auth denied")
        }
        setAuthorize(scope, authorized)
      }
    } catch (error) {
      invokeFailure(Events.GET_USER_INFO, options, scope + error)
    }
  }, options)
}
