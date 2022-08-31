import { AsyncReturn, GeneralCallbackResult, invokeCallback, wrapperAsyncAPI } from "@evoker/bridge"
import { invokeWebViewMethod } from "../../fromWebView"

const enum Events {
  LOAD_FONT_FACE = "loadFontFace"
}

interface LoadFontFaceDesc {
  /** 字体样式，
   * 可选值为 https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-style#values */
  style?: string
  /** 字体粗细，
   * 可选值为 https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-weight#values */
  weight?: string
  /** 设置小型大写字母的字体显示文本，
   * 可选值为 https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-variant#values */
  variant?: string
}

interface LoadFontFaceOptions {
  /** 定义的字体名称 */
  family: string
  /** 字体资源的地址 */
  source: string
  /** 可选的字体描述符 */
  desc?: LoadFontFaceDesc
  /** 接口调用成功的回调函数 */
  success?: LoadFontFaceSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: LoadFontFaceFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: LoadFontFaceCompleteCallback
}

interface LoadFontFaceSuccessCallbackResukt {
  status: string
}

type LoadFontFaceSuccessCallback = (res: LoadFontFaceSuccessCallbackResukt) => void

type LoadFontFaceFailCallback = (res: GeneralCallbackResult) => void

type LoadFontFaceCompleteCallback = (res: GeneralCallbackResult) => void

/** 动态加载网络字体，文件地址需为下载类型 */
export function loadFontFace<T extends LoadFontFaceOptions = LoadFontFaceOptions>(
  options: T
): AsyncReturn<T, LoadFontFaceOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.LOAD_FONT_FACE
      invokeWebViewMethod(event, options, result => {
        invokeCallback(event, options, result)
      })
    },
    options,
    { desc: { style: "normal", weight: "normal", variant: "normal" } }
  )
}
