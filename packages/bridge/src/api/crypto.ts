import { isNumber } from "@evoker/shared"
import { invoke } from "../bridge"
import {
  invokeCallback,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeSuccess
} from "../async"
import { fetchArrayBuffer } from "../utils"
import { isString } from "@vue/shared"
import { ERR_CANNOT_EMPTY, ERR_INVALID_ARG_TYPE } from "../errors"

const enum Events {
  RSA = "rsa",
  GET_RANDOM_VALUES = "getRandomValues"
}

interface RSAOptions {
  /** 使用 RSA 加密还是 RSA 解密
   *
   * 可选值：
   * - encrypt: 加密
   * - decrypt: 解密
   */
  action: "encrypt" | "decrypt"
  /** 要处理的文本，加密为原始文本，解密为 Base64 编码格式文本 */
  text: string
  /** RSA 密钥，加密使用公钥，解密使用私钥 */
  key: string
  /** 接口调用成功的回调函数 */
  success?: RSASuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: RSAFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: RSACompleteCallback
}

interface RSASuccessCallbackResult {
  /** 经过处理过后得到的文本，加密为 Base64编码文本，解密为原始文本 */
  text: string
}

type RSASuccessCallback = (res: RSASuccessCallbackResult) => void

type RSAFailCallback = (res: GeneralCallbackResult) => void

type RSACompleteCallback = (res: GeneralCallbackResult) => void

/** 非对称加解密 */
export function rsa<T extends RSAOptions = RSAOptions>(options: T): AsyncReturn<T, RSAOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.RSA
    if (!isString(options.key)) {
      invokeFailure(event, options, ERR_INVALID_ARG_TYPE("options.key", "string", options.key))
      return
    }

    if (!options.key) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.key", options.key, ERR_CANNOT_EMPTY)
      )
      return
    }

    if (!isString(options.text)) {
      invokeFailure(event, options, ERR_INVALID_ARG_TYPE("options.text", "string", options.text))
      return
    }

    if (!options.text) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.text", options.text, ERR_CANNOT_EMPTY)
      )
      return
    }

    const validTypes = ["encrypt", "decrypt"]
    if (!validTypes.includes(options.action)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.action", validTypes, options.action)
      )
      return
    }

    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetRandomValuesOptions {
  /** 整数，生成随机数的字节数，最大 1048576 */
  length: number
  /** 接口调用成功的回调函数 */
  success?: GetRandomValuesSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: GetRandomValuesFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: GetRandomValuesCompleteCallback
}

interface GetRandomValuesSuccessCallbackResult {
  /** 随机数内容，长度为传入的字节数 */
  randomValues: ArrayBuffer
}

type GetRandomValuesSuccessCallback = (res: GetRandomValuesSuccessCallbackResult) => void

type GetRandomValuesFailCallback = (res: GeneralCallbackResult) => void

type GetRandomValuesCompleteCallback = (res: GeneralCallbackResult) => void

/** 获取密码学安全随机数 */
export function getRandomValues<T extends GetRandomValuesOptions = GetRandomValuesOptions>(
  options: T
): AsyncReturn<T, GetRandomValuesOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.GET_RANDOM_VALUES
    if (!isNumber(options.length) || options.length <= 0 || options.length > 1048576) {
      invokeFailure(event, options, "invalid length")
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
      } else {
        fetchArrayBuffer(result.data, "randomValues")
        invokeSuccess(event, options, result.data)
      }
    })
  }, options)
}
