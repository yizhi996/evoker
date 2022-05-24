import { isFunction, extend } from "@nzoth/shared"
import { InvokeCallbackResult, subscribeHandler } from "./bridge"

export interface GeneralCallbackResult {
  errMsg: string
}

export interface SuccessCallback {
  success?: (...args: any) => any
}

export interface CallbackOptions {
  success?: (...args: any) => any
  fail?: (...args: any) => any
  complete?: (...args: any) => any
}

export type SuccessResult<T extends CallbackOptions> = Parameters<
  Exclude<T["success"], undefined>
>[0]

export type PromiseSuccessResult<T extends CallbackOptions> = Promise<SuccessResult<T>>

export type AsyncReturn<T, U extends CallbackOptions> = T extends {
  success: (...args: any) => any
}
  ? void
  : T extends { fail: (...args: any) => any }
  ? void
  : T extends { complete: (...args: any) => any }
  ? void
  : PromiseSuccessResult<U>

function promisify<T extends SuccessCallback>(
  fn: Function,
  options: Omit<T, "success" | "fail">
): PromiseSuccessResult<T> {
  return new Promise((resolve, reject) => {
    const finalOptions = extend({}, options, {
      success: resolve,
      fail: reject
    })
    fn(finalOptions)
  })
}

function isPromiseLike(val: any) {
  return !val.success && !val.fail && !val.complete
}

export function wrapperAsyncAPI<T>(fn: (options: T) => void, options: T): any {
  const _options = options || ({} as T)
  if (isPromiseLike(_options)) {
    return promisify(fn, _options)
  }
  fn(_options)
}

export function invokeSuccess<
  T = Record<string, unknown>,
  U extends CallbackOptions = CallbackOptions
>(event: string, options: U, result: T) {
  ;(result as T & { errMsg: string }).errMsg = `${event}:ok`
  isFunction(options.success) && options.success(result)
  isFunction(options.complete) && options.complete(result)
}

export function invokeFailure<T extends CallbackOptions = CallbackOptions>(
  event: string,
  options: T,
  errMsg: string
) {
  const obj = { errMsg: `${event}:fail ${errMsg}` }
  isFunction(options.fail) && options.fail(obj)
  isFunction(options.complete) && options.complete(obj)
  typeof window === "undefined" && subscribeHandler("APP_ON_ERROR", new Error(obj.errMsg))
}

export function invokeCallback<
  T = Record<string, unknown>,
  U extends CallbackOptions = CallbackOptions
>(event: string, options: U, result: InvokeCallbackResult<T>) {
  if (result.errMsg) {
    invokeFailure(event, options, result.errMsg)
  } else {
    invokeSuccess(event, options, result.data)
  }
}
