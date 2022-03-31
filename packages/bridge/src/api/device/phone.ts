import { isNumber, isString } from "@nzoth/shared"
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

const enum Events {
  MAKE_PHONE_CALL = "makePhoneCall"
}

interface MakePhoneCallOptions {
  phoneNumber: string
  success?: MakePhoneCallSuccessCallback
  fail?: MakePhoneCallFailCallback
  complete?: MakePhoneCallCompleteCallback
}

type MakePhoneCallSuccessCallback = (res: GeneralCallbackResult) => void

type MakePhoneCallFailCallback = (res: GeneralCallbackResult) => void

type MakePhoneCallCompleteCallback = (res: GeneralCallbackResult) => void

export function makePhoneCall<
  T extends MakePhoneCallOptions = MakePhoneCallOptions
>(options: T): AsyncReturn<T, MakePhoneCallOptions> {
  return wrapperAsyncAPI<T>(options => {
    if (!options.phoneNumber) {
      invokeFailure(
        Events.MAKE_PHONE_CALL,
        options,
        "phoneNumber cannot be empty"
      )
      return
    }
    let phoneNumber = options.phoneNumber
    if (isNumber(phoneNumber) || !isString(phoneNumber)) {
      phoneNumber = options.phoneNumber.toString()
    }

    showActionSheet({ alertText: phoneNumber, itemList: ["呼叫"] })
      .then(result => {
        const tapIndex = result.tapIndex
        if (tapIndex === -1) {
          invokeFailure(Events.MAKE_PHONE_CALL, options, "error")
        } else if (tapIndex === 0) {
          invoke<SuccessResult<T>>(
            Events.MAKE_PHONE_CALL,
            { phoneNumber },
            result => {
              invokeCallback(Events.MAKE_PHONE_CALL, options, result)
            }
          )
        }
      })
      .catch(error => {
        invokeFailure(Events.MAKE_PHONE_CALL, options, error)
      })
  }, options)
}
