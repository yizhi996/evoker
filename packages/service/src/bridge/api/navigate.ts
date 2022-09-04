import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure,
  ERR_INVALID_ARG_TYPE,
  ERR_CANNOT_EMPTY,
  ERR_INVALID_ARG_VALUE
} from "@evoker/bridge"
import { innerAppData } from "../../app"
import { isString } from "@vue/shared"

const enum Events {
  NAVIGATE_TO_MINI_PROGRAM = "navigateToMiniProgram",
  EXIT_MINI_PROGRAM = "exitMiniProgram"
}

interface NavigateToMiniProgramOptions {
  /** 要打开的小程序 appId */
  appId: string
  /** 打开的页面路径，如果为空则打开首页，目标小程序可在 App.onLaunch，App.onShow， Page.onLoad 中获取 */
  path?: string
  /** 需要传递给目标小程序的数据，目标小程序可在 App.onLaunch，App.onShow 中获取 */
  extraData?: object
  /** 要打开的小程序版本。仅在当前小程序为开发版或体验版时此参数有效。如果当前小程序是正式版，则打开的小程序必定是正式版 */
  envVersion?: "release" | "trial" | "develop"
  /** 接口调用成功的回调函数 */
  success?: NavigateToMiniProgramSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: NavigateToMiniProgramFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: NavigateToMiniProgramCompleteCallback
}

type NavigateToMiniProgramSuccessCallback = (res: GeneralCallbackResult) => void

type NavigateToMiniProgramFailCallback = (res: GeneralCallbackResult) => void

type NavigateToMiniProgramCompleteCallback = (res: GeneralCallbackResult) => void

/** 打开另一个小程序，每一次跳转前都会弹窗确认 */
export function navigateToMiniProgram<
  T extends NavigateToMiniProgramOptions = NavigateToMiniProgramOptions
>(options: T): AsyncReturn<T, NavigateToMiniProgramOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.NAVIGATE_TO_MINI_PROGRAM

      if (!isString(options.appId)) {
        invokeFailure(
          event,
          options,
          ERR_INVALID_ARG_TYPE("options.appId", "string", options.appId)
        )
        return
      }

      if (!options.appId) {
        invokeFailure(
          event,
          options,
          ERR_INVALID_ARG_VALUE("options.appId", options.appId, ERR_CANNOT_EMPTY)
        )
        return
      }

      const validEnv = ["release", "trial", "develop"]
      if (!validEnv.includes(options.envVersion!)) {
        invokeFailure(
          event,
          options,
          ERR_INVALID_ARG_TYPE("options.envVersion", validEnv, options.envVersion)
        )
        return
      }

      if (options.extraData) {
        ;(options as T & { extraDataString: string }).extraDataString = JSON.stringify(
          options.extraData
        )
        options.extraData = undefined
      }

      InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { envVersion: "release" }
  )
}

interface ExitMiniProgramOptions {
  /** 接口调用成功的回调函数 */
  success?: ExitMiniProgramSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ExitMiniProgramFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ExitMiniProgramCompleteCallback
}

type ExitMiniProgramSuccessCallback = (res: GeneralCallbackResult) => void

type ExitMiniProgramFailCallback = (res: GeneralCallbackResult) => void

type ExitMiniProgramCompleteCallback = (res: GeneralCallbackResult) => void

/** 退出当前小程序，必须由用户点击才能调用成功。 */
export function exitMiniProgram<T extends ExitMiniProgramOptions = ExitMiniProgramOptions>(
  options: T
): AsyncReturn<T, ExitMiniProgramOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.EXIT_MINI_PROGRAM
    if (!innerAppData.eventFromUserClick) {
      invokeFailure(event, options, "can only be invoked by user click gesture.")
      return
    }
    InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
