import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../../async"

interface ScanCodeOptions {
  /** 是否只能从相机扫码，不允许从相册选择图片 */
  onlyFromCamera?: boolean
  /** 扫码类型 */
  scanType?: Array<"barCode" | "qrCode">
  /** 接口调用成功的回调函数 */
  success?: ScanCodeSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ScanCodeFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ScanCodeCompleteCallback
}

interface ScanCodeSuccessCallbackResult {
  /** 所扫码的内容 */
  result: string
  /** 所扫码的类型
   *
   * 合法值：
   * - QR_CODE:	二维码
   * - AZTEC:	一维码
   * - CODABAR:	一维码
   * - CODE_39:	一维码
   * - CODE_93:	一维码
   * - CODE_128: 一维码
   * - DATA_MATRIX: 一维码
   * - EAN_8:	一维码
   * - EAN_13: 一维码
   * - ITF:	一维码
   * - PDF_417:	二维码
   * - RSS_14: 一维码
   * - RSS_EXPANDED: 一维码
   * - UPC_E: 一维码
   * - CODE_25: 一维码
   */
  scanType: string
}

type ScanCodeSuccessCallback = (res: ScanCodeSuccessCallbackResult) => void

type ScanCodeFailCallback = (res: GeneralCallbackResult) => void

type ScanCodeCompleteCallback = (res: GeneralCallbackResult) => void

/** 调起客户端扫码界面进行扫码 */
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
