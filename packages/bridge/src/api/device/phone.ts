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
import { ErrorCodes, errorMessage } from "../../errors"

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

export function makePhoneCall<T extends MakePhoneCallOptions = MakePhoneCallOptions>(
  options: T
): AsyncReturn<T, MakePhoneCallOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.MAKE_PHONE_CALL
    if (options.phoneNumber == null) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "phoneNumber"))
      return
    }
    if (!options.phoneNumber) {
      invokeFailure(event, options, errorMessage(ErrorCodes.CANNOT_BE_EMPTY, "phoneNumber"))
      return
    }
    let phoneNumber = options.phoneNumber
    if (isNumber(phoneNumber) || !isString(phoneNumber)) {
      phoneNumber = options.phoneNumber.toString()
    }

    showActionSheet({ alertText: phoneNumber, itemList: ["呼叫"] })
      .then(() => {
        invoke<SuccessResult<T>>(event, { phoneNumber }, result => {
          invokeCallback(event, options, result)
        })
      })
      .catch(error => {
        invokeFailure(event, options, error)
      })
  }, options)
}
