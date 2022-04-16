import {
  AsyncReturn,
  GeneralCallbackResult,
  invokeCallback,
  wrapperAsyncAPI
} from "@nzoth/bridge"
import { invokeWebViewMethod } from "../../fromWebView"
import { extend } from "@nzoth/shared"

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

type LoadFontFaceSuccessCallback = (res: GeneralCallbackResult) => void

type LoadFontFaceFailCallback = (res: GeneralCallbackResult) => void

type LoadFontFaceCompleteCallback = (res: GeneralCallbackResult) => void

export function loadFontFace<
  T extends LoadFontFaceOptions = LoadFontFaceOptions
>(options: T): AsyncReturn<T, LoadFontFaceOptions> {
  return wrapperAsyncAPI<T>(options => {
    const defaultDesc = {
      style: "normal",
      weight: "normal",
      variant: "normal"
    }
    invokeWebViewMethod(
      Events.LOAD_FONT_FACE,
      {
        family: options.family,
        source: options.source,
        desc: extend(defaultDesc, options.desc)
      },
      result => {
        invokeCallback(Events.LOAD_FONT_FACE, options, result)
      }
    )
  }, options)
}
