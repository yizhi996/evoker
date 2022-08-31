import { AsyncReturn, GeneralCallbackResult, invokeSuccess, wrapperAsyncAPI } from "@evoker/bridge"
import { invokeWebViewMethod } from "../../fromWebView"

const enum Events {
  PAGE_SCROLL_TO = "pageScrollTo"
}

interface PageScrollToOptions {
  /** 滚动到页面的目标位置，单位 px */
  scrollTop?: number
  /** 滚动动画的时长，单位 ms */
  duration?: number
  /** CSS 选择器 */
  selector?: string
  /** 偏移距离，需要和 selector 参数搭配使用，可以滚动到 selector 加偏移距离的位置，单位 px */
  offsetTop?: number
  /** 接口调用成功的回调函数 */
  success?: PageScrollToSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: PageScrollToFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: PageScrollToCompleteCallback
}

type PageScrollToSuccessCallback = (res: GeneralCallbackResult) => void

type PageScrollToFailCallback = (res: GeneralCallbackResult) => void

type PageScrollToCompleteCallback = (res: GeneralCallbackResult) => void

/** 将页面滚动到目标位置，支持选择器和滚动距离两种方式定位 */
export function pageScrollTo<T extends PageScrollToOptions = PageScrollToOptions>(
  options: T
): AsyncReturn<T, PageScrollToOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.PAGE_SCROLL_TO
      invokeWebViewMethod(event, options)
      invokeSuccess(event, options, {})
    },
    options,
    { duration: 300 }
  )
}
