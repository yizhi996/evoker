import { invoke } from "../bridge"
import {
  invokeCallback,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../async"
import { extend } from "@nzoth/shared"

const enum Events {
  NAVIGATE_TO_MINI_PROGRAM = "navigateToMiniProgram"
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

type NavigateToMiniProgramCompleteCallback = (
  res: GeneralCallbackResult
) => void

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
      invokeFailure(
        event,
        finalOptions,
        "options envVersion required release, trial or develop"
      )
      return
    }

    if (finalOptions.extraData) {
      ;(finalOptions as T & { extraDataString: string }).extraDataString =
        JSON.stringify(finalOptions.extraData)
      finalOptions.extraData = undefined
    }

    invoke<SuccessResult<T>>(event, finalOptions, result => {
      invokeCallback(event, finalOptions, result)
    })
  }, options)
}
