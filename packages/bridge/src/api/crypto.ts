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

export function rsa<T extends RSAOptions = RSAOptions>(
  options: T
): AsyncReturn<T, RSAOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.RSA, options, result => {
      invokeCallback(Events.RSA, options, result)
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

export function getRandomValues<
  T extends GetRandomValuesOptions = GetRandomValuesOptions
>(options: T): AsyncReturn<T, GetRandomValuesOptions> {
  return wrapperAsyncAPI<T>(options => {
    if (
      !isNumber(options.length) ||
      options.length <= 0 ||
      options.length > 1048576
    ) {
      invokeFailure(Events.GET_RANDOM_VALUES, options, "invalid length")
      return
    }

    invoke<SuccessResult<T>>(Events.GET_RANDOM_VALUES, options, result => {
      invokeCallback(Events.GET_RANDOM_VALUES, options, result)
    })
  }, options)
}
