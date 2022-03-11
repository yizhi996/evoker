import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  invokeFailure,
  wrapperAsyncAPI
} from "../bridge"

const enum Events {
  NavigateToMiniProgram = "navigateToMiniProgram"
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
    const finalOptions = Object.assign(
      {
        appId: "",
        envVersion: "release"
      },
      options
    )

    if (!finalOptions.appId) {
      invokeFailure(
        Events.NavigateToMiniProgram,
        finalOptions,
        "options required appId"
      )
      return
    }

    if (!["release", "trial", "develop"].includes(finalOptions.envVersion!)) {
      invokeFailure(
        Events.NavigateToMiniProgram,
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

    invoke<SuccessResult<T>>(
      Events.NavigateToMiniProgram,
      finalOptions,
      result => {
        invokeCallback(Events.NavigateToMiniProgram, finalOptions, result)
      }
    )
  }, options)
}
