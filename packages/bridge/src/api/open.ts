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
  /** 接口调用成功的回调函数 */
  success?: LoginSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: LoginFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
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
  /** 接口调用成功的回调函数 */
  success?: CheckSessionSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CheckSessionFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
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
