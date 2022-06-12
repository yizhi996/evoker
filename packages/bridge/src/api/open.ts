import { invoke } from "../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI
} from "../async"

const enum Events {
  LOGIN = "login",
  CHECK_SESSION = "checkSession"
}

interface LoginOptions {
  success?: LoginSuccessCallback
  fail?: LoginFailCallback
  complete?: LoginCompleteCallback
}

interface LoginSuccessCallbackResult {
  code: string
}

type LoginSuccessCallback = (res: LoginSuccessCallbackResult) => void

type LoginFailCallback = (res: GeneralCallbackResult) => void

type LoginCompleteCallback = (res: GeneralCallbackResult) => void

export function login<T extends LoginOptions = LoginOptions>(
  options: T
): AsyncReturn<T, LoginOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.LOGIN
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}

interface CheckSessionOptions {
  success?: CheckSessionSuccessCallback
  fail?: CheckSessionFailCallback
  complete?: CheckSessionCompleteCallback
}

type CheckSessionSuccessCallback = (res: GeneralCallbackResult) => void

type CheckSessionFailCallback = (res: GeneralCallbackResult) => void

type CheckSessionCompleteCallback = (res: GeneralCallbackResult) => void

export function checkSession<T extends CheckSessionOptions = CheckSessionOptions>(
  options: T
): AsyncReturn<T, CheckSessionOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.CHECK_SESSION
    invoke<SuccessResult<T>>(event, options, result => {
      invokeCallback(event, options, result)
    })
  }, options)
}
