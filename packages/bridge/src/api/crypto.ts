import { isNumber } from "@nzoth/shared"
import { invoke } from "../bridge"
import {
  invokeCallback,
  invokeFailure,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../async"
import { ErrorCodes, errorMessage } from "../errors"

const enum Events {
  RSA = "rsa",
  GET_RANDOM_VALUES = "getRandomValues"
}

interface RSAOptions {
  action: "encrypt" | "decrypt"
  text: string
  key: string
  success?: RSASuccessCallback
  fail?: RSAFailCallback
  complete?: RSACompleteCallback
}

interface RSASuccessCallbackResult {
  text: string
}

type RSASuccessCallback = (res: RSASuccessCallbackResult) => void

type RSAFailCallback = (res: GeneralCallbackResult) => void

type RSACompleteCallback = (res: GeneralCallbackResult) => void

export function rsa<T extends RSAOptions = RSAOptions>(options: T): AsyncReturn<T, RSAOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.RSA
    if (!options.key) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "key"))
      return
    }
    if (!options.text) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "text"))
      return
    }
    if (!["encrypt", "decrypt"].includes(options.action)) {
      invokeFailure(
        event,
        options,
        errorMessage(ErrorCodes.ILLEGAL_VALUE, "action, this valid values are encrypt or decrypt")
      )
      return
    }
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface GetRandomValuesOptions {
  length: number
  success?: GetRandomValuesSuccessCallback
  fail?: GetRandomValuesFailCallback
  complete?: GetRandomValuesCompleteCallback
}

type GetRandomValuesSuccessCallback = (res: GeneralCallbackResult) => void

type GetRandomValuesFailCallback = (res: GeneralCallbackResult) => void

type GetRandomValuesCompleteCallback = (res: GeneralCallbackResult) => void

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
      invokeCallback(event, options, result)
    })
  }, options)
}
