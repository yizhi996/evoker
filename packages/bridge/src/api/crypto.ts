import {
  invoke,
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../bridge"

const enum Events {
  RSA = "rsa"
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
