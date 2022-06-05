import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

interface ScanCodeOptions {
  onlyFromCamera?: boolean
  scanType?: Array<"barCode" | "qrCode">
  success?: ScanCodeSuccessCallback
  fail?: ScanCodeFailCallback
  complete?: ScanCodeCompleteCallback
}

interface ScanCodeSuccessCallbackResult {
  result: string
  scanType: string
}

type ScanCodeSuccessCallback = (res: ScanCodeSuccessCallbackResult) => void

type ScanCodeFailCallback = (res: GeneralCallbackResult) => void

type ScanCodeCompleteCallback = (res: GeneralCallbackResult) => void

export function scanCode<T extends ScanCodeOptions = ScanCodeOptions>(
  options: T
): AsyncReturn<T, ScanCodeOptions> {
  return wrapperAsyncAPI(
    options => {
      invoke<SuccessResult<T>>("scanCode", options, result => {
        invokeCallback("scanCode", options, result)
      })
    },
    options,
    {
      onlyFromCamera: false,
      scanType: ["barCode", "qrCode"]
    }
  )
}
