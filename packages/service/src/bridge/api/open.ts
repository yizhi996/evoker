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
} from "@evoker/bridge"
import { innerAppData } from "../../app"
import { extend } from "@vue/shared"

const enum Events {
  GET_USER_PRIFILE = "getUserProfile",
  GET_USER_INFO = "getUserProfile"
}

interface GetUserProfileOptions {
  lang?: "en" | "zh_CN" | "zh_TW"
  desc: string
  /** 接口调用成功的回调函数 */
  success?: GetUserProfileSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetUserProfileFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetUserProfileCompleteCallback
}

type GetUserProfileSuccessCallback = (res: GeneralCallbackResult) => void

type GetUserProfileFailCallback = (res: GeneralCallbackResult) => void

type GetUserProfileCompleteCallback = (res: GeneralCallbackResult) => void

/** 统一的获取用户信息接口，需要在 Native 自行实现，也可以不使用本接口，直接在 JS 端自行实现。
 *
 * 本接口只能在 @click 事件内调用，每次调用都会弹窗请求授权。
 */
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

/** 统一的获取用户信息接口，需要在 Native 自行实现，也可以不使用本接口，直接在 JS 端自行实现
 * 
 * 需要用户授权 `scope.userInfo`
 */
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
