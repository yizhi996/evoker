import { InnerJSBridge } from "../bridge"
import {
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI,
  AsyncReturn,
  invokeFailure
} from "@nzoth/bridge"
import { extend } from "@nzoth/shared"
import { innerAppData } from "../../app"

const enum Events {
  NAVIGATE_TO_MINI_PROGRAM = "navigateToMiniProgram",
  EXIT_MINI_PROGRAM = "exitMiniProgram"
}

interface NavigateToMiniProgramOptions {
  appId: string
  path?: string
  extraData?: object
  envVersion?: "release" | "trial" | "develop"
  success?: NavigateToMiniProgramSuccessCallback
  fail?: NavigateToMiniProgramFailCallback
  complete?: NavigateToMiniProgramCompleteCallback
}

type NavigateToMiniProgramSuccessCallback = (res: GeneralCallbackResult) => void

type NavigateToMiniProgramFailCallback = (res: GeneralCallbackResult) => void

type NavigateToMiniProgramCompleteCallback = (res: GeneralCallbackResult) => void

export function navigateToMiniProgram<
  T extends NavigateToMiniProgramOptions = NavigateToMiniProgramOptions
>(options: T): AsyncReturn<T, NavigateToMiniProgramOptions> {
  return wrapperAsyncAPI<T>(options => {
    const event = Events.NAVIGATE_TO_MINI_PROGRAM
    const finalOptions = extend(
      {
        appId: "",
        envVersion: "release"
      },
      options
    )

    if (!finalOptions.appId) {
      invokeFailure(event, finalOptions, "options required appId")
      return
    }

    if (!["release", "trial", "develop"].includes(finalOptions.envVersion!)) {
      invokeFailure(event, finalOptions, "options envVersion required release, trial or develop")
      return
    }

    if (finalOptions.extraData) {
      ;(finalOptions as T & { extraDataString: string }).extraDataString = JSON.stringify(
        finalOptions.extraData
      )
      finalOptions.extraData = undefined
    }

    InnerJSBridge.invoke<SuccessResult<T>>(event, finalOptions, result => {
      invokeCallback(event, finalOptions, result)
    })
  }, options)
}

interface ExitMiniProgramOptions {
  success?: ExitMiniProgramSuccessCallback
  fail?: ExitMiniProgramFailCallback
  complete?: ExitMiniProgramCompleteCallback
}

type ExitMiniProgramSuccessCallback = (res: GeneralCallbackResult) => void

type ExitMiniProgramFailCallback = (res: GeneralCallbackResult) => void

type ExitMiniProgramCompleteCallback = (res: GeneralCallbackResult) => void

export function exitMiniProgram<T extends ExitMiniProgramOptions = ExitMiniProgramOptions>(
  options: T
): AsyncReturn<T, ExitMiniProgramOptions> {
  return wrapperAsyncAPI<T>(options => {
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
