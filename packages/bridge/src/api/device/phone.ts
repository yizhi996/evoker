import { isString } from "@vue/shared"
import { invoke } from "../../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeFailure
} from "../../async"
import { showActionSheet } from "../ui/interaction"
import { ERR_CANNOT_EMPTY, ERR_INVALID_ARG_TYPE, ERR_INVALID_ARG_VALUE } from "../../errors"

const enum Events {
  MAKE_PHONE_CALL = "makePhoneCall"
}

interface MakePhoneCallOptions {
  /** 需要拨打的电话号码 */
  phoneNumber: string
  /** 接口调用成功的回调函数 */
  success?: MakePhoneCallSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: MakePhoneCallFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: MakePhoneCallCompleteCallback
}

type MakePhoneCallSuccessCallback = (res: GeneralCallbackResult) => void

type MakePhoneCallFailCallback = (res: GeneralCallbackResult) => void

type MakePhoneCallCompleteCallback = (res: GeneralCallbackResult) => void

/** 拨打电话 */
export function makePhoneCall<T extends MakePhoneCallOptions = MakePhoneCallOptions>(
  options: T
): AsyncReturn<T, MakePhoneCallOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.MAKE_PHONE_CALL
    if (!isString(options.phoneNumber)) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_TYPE("options.phoneNumber", "string", options.phoneNumber)
      )
      return
    }

    if (!options.phoneNumber) {
      invokeFailure(
        event,
        options,
        ERR_INVALID_ARG_VALUE("options.phoneNumber", options.phoneNumber, ERR_CANNOT_EMPTY)
      )
      return
    }

    showActionSheet({ alertText: options.phoneNumber, itemList: ["呼叫"] })
      .then(() => {
        invoke<SuccessResult<T>>(event, options, result => {
          invokeCallback(event, options, result)
        })
      })
      .catch(error => {
        invokeFailure(event, options, error)
      })
  }, options)
}
