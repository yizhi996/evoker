import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../bridge"

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
  return wrapperAsyncAPI<T>(options => {
    const finalOptions = Object.assign(
      {
        onlyFromCamera: false,
        scanType: ["barCode", "qrCode"]
      },
      options
    )
    invoke<SuccessResult<T>>("scanCode", finalOptions, result => {
      invokeCallback("scanCode", finalOptions, result)
    })
  }, options)
}
