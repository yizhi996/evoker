import {
  AsyncReturn,
  GeneralCallbackResult,
  invokeSuccess,
  wrapperAsyncAPI
} from "@nzoth/bridge"
import { invokeWebViewMethod } from "../../fromWebView"
import { extend } from "@nzoth/shared"

interface PageScrollToOptions {
  scrollTop?: number
  duration?: number
  selector?: string
  offsetTop?: number
  success?: PageScrollToSuccessCallback
  fail?: PageScrollToFailCallback
  complete?: PageScrollToCompleteCallback
}

const enum Events {
  PAGE_SCROLL_TO = "pageScrollTo"
}

type PageScrollToSuccessCallback = (res: GeneralCallbackResult) => void

type PageScrollToFailCallback = (res: GeneralCallbackResult) => void

type PageScrollToCompleteCallback = (res: GeneralCallbackResult) => void

export function pageScrollTo<
  T extends PageScrollToOptions = PageScrollToOptions
>(options: T): AsyncReturn<T, PageScrollToOptions> {
  return wrapperAsyncAPI<T>(options => {
    invokeWebViewMethod(
      Events.PAGE_SCROLL_TO,
      extend({ duration: 300 }, options)
    )
    invokeSuccess(Events.PAGE_SCROLL_TO, options, {})
  }, options)
}
