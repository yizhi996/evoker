import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure,
  openAuthorizationView
} from "@nzoth/bridge"
import { innerAppData } from "../../app"

const enum Events {
  GET_USER_PRIFILE = "getUserProfile"
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

export function getUserProfile<
  T extends GetUserProfileOptions = GetUserProfileOptions
>(options: T): AsyncReturn<T, GetUserProfileOptions> {
  return wrapperAsyncAPI<T>(async options => {
    if (!innerAppData.eventFromUserClick) {
      invokeFailure(
        Events.GET_USER_PRIFILE,
        options,
        "can only be invoked by user click gesture."
      )
      return
    }
    const accepted = await openAuthorizationView("scope.userInfo")
    if (accepted) {
      InnerJSBridge.invoke<SuccessResult<T>>(
        Events.GET_USER_PRIFILE,
        Object.assign({ lang: "en", desc: "" }, options),
        result => {
          invokeCallback(Events.GET_USER_PRIFILE, options, result)
        }
      )
    } else {
      invokeFailure(Events.GET_USER_PRIFILE, options, "fail auth deny")
    }
  }, options)
}
