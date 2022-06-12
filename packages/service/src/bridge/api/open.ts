import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure,
  openAuthorizationView,
  getAuthorize,
  AuthorizationStatus
} from "@nzoth/bridge"
import { innerAppData } from "../../app"
import { extend } from "@nzoth/shared"

const enum Events {
  GET_USER_PRIFILE = "getUserProfile",
  GET_USER_INFO = "getUserProfile"
}

interface GetUserProfileOptions {
  lang?: "en" | "zh_CN" | "zh_TW"
  desc: string
  success?: GetUserProfileSuccessCallback
  fail?: GetUserProfileFailCallback
  complete?: GetUserProfileCompleteCallback
}

type GetUserProfileSuccessCallback = (res: GeneralCallbackResult) => void

type GetUserProfileFailCallback = (res: GeneralCallbackResult) => void

type GetUserProfileCompleteCallback = (res: GeneralCallbackResult) => void

export function getUserProfile<T extends GetUserProfileOptions = GetUserProfileOptions>(
  options: T
): AsyncReturn<T, GetUserProfileOptions> {
  return wrapperAsyncAPI(async options => {
    const event = Events.GET_USER_PRIFILE
    if (!innerAppData.eventFromUserClick) {
      invokeFailure(event, options, "can only be invoked by user click gesture.")
      return
    }
    const accepted = await openAuthorizationView("scope.userInfo")
    if (accepted) {
      InnerJSBridge.invoke<SuccessResult<T>>(
        event,
        extend({ lang: "en", desc: "" }, options),
        result => {
          invokeCallback(event, options, result)
        }
      )
    } else {
      invokeFailure(event, options, "fail auth deny")
    }
  }, options)
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

      getAuthorize(scope).then(status => {
        if (status === AuthorizationStatus.authorized) {
          InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
            invokeCallback(event, options, result)
          })
        } else {
          invokeFailure(event, options, "not authorized")
        }
      })
    },
    options,
    { withCredentials: false, lang: "en" }
  )
}
