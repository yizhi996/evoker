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

export type PromiseSuccessResult<T extends CallbackOptions> = Promise<
  SuccessResult<T>
>

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
    const finalOptions = Object.assign({}, options, {
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
  typeof options.success === "function" && options.success(result)
  typeof options.complete == "function" && options.complete(result)
}

export function invokeFailure<T extends CallbackOptions = CallbackOptions>(
  event: string,
  options: T,
  errMsg: string
) {
  const final = `${event}:fail ${errMsg}`
  typeof options.fail === "function" && options.fail({ errMsg: final })
  typeof options.complete == "function" && options.complete({ errMsg: final })
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

let callbackId = 0

export type InvokeCallback<T> = (result: InvokeCallbackResult<T>) => void

export interface InvokeCallbackResult<T = Record<string, any>> {
  id: number
  event: string
  errMsg: string
  data?: T
}

const callbacks = new Map<number, InvokeCallback<any>>()

export type SubscribeCallback<T> = (result: T, webViewId: number) => void

const subscribes = new Map<string, SubscribeCallback<any>>()

export function publish(
  event: string,
  params: Record<string, any> = {},
  webViewId: number
) {
  if (globalThis.__NZAppServiceNativeSDK) {
    globalThis.__NZAppServiceNativeSDK.messageChannel.publishHandler.postMessage(
      {
        event,
        params: JSON.stringify(params),
        webViewId: webViewId
      }
    )
  } else if (globalThis.webkit) {
    globalThis.webkit.messageHandlers.publishHandler.postMessage({
      event,
      params: JSON.stringify(params),
      webViewId: webViewId
    })
  }
}

export function subscribe<T = unknown>(
  event: string,
  callback: SubscribeCallback<T>
) {
  subscribes.set(event, callback)
}

export function subscribeHandler(
  event: string,
  message: any,
  webViewId: number = 0
) {
  const callback = subscribes.get(event)
  if (callback) {
    callback(message, webViewId)
  }
}

export function invoke<T = unknown>(
  event: string,
  params: Record<string, any> = {},
  callback?: InvokeCallback<T>
) {
  const cbId = callbackId++
  if (callback) {
    callbacks.set(cbId, callback)
  }

  if (globalThis.__NZAppServiceNativeSDK) {
    const msg = {
      event,
      params: JSON.stringify(params),
      callbackId: cbId
    }
    globalThis.__NZAppServiceNativeSDK.messageChannel.invokeHandler.postMessage(
      msg
    )
  } else if (globalThis.webkit) {
    const msg = {
      event,
      params: JSON.stringify(params),
      callbackId: cbId
    }
    globalThis.webkit.messageHandlers.invokeHandler.postMessage(msg)
  }
}

export function invokeCallbackHandler(result: InvokeCallbackResult<unknown>) {
  const callback = callbacks.get(result.id)
  if (callback) {
    if (typeof result.data === "string") {
      try {
        result.data = JSON.parse(result.data)
      } catch (e) {}
    }
    callback(result)
    callbacks.delete(result.id)
  }
}
