import { AsyncReturn, GeneralCallbackResult, invokeCallback, wrapperAsyncAPI } from "@nzoth/bridge"
import { invokeWebViewMethod } from "../../fromWebView"

const enum Events {
  LOAD_FONT_FACE = "loadFontFace"
}

interface LoadFontFaceDesc {
  style?: string
  weight?: string
  variant?: string
}

interface LoadFontFaceOptions {
  family: string
  source: string
  desc?: LoadFontFaceDesc
  success?: LoadFontFaceSuccessCallback
  fail?: LoadFontFaceFailCallback
  complete?: LoadFontFaceCompleteCallback
}

interface LoadFontFaceSuccessCallbackResukt {
  status: string
}

type LoadFontFaceSuccessCallback = (res: LoadFontFaceSuccessCallbackResukt) => void

type LoadFontFaceFailCallback = (res: GeneralCallbackResult) => void

type LoadFontFaceCompleteCallback = (res: GeneralCallbackResult) => void

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
