import {
  AsyncReturn,
  fetchArrayBuffer,
  GeneralCallbackResult,
  invokeCallback,
  invokeFailure,
  invokeSuccess,
  wrapperAsyncAPI
} from "@evoker/bridge"
import { InnerJSBridge } from "../../bridge"
import { extend, isFunction, isString } from "@vue/shared"
import { headerValueToString } from "./util"
import { isArrayBuffer } from "@evoker/shared"

const main = {}

const weakMainTask = new WeakMap<object, SocketTask>()

const mainEventListener = new WeakMap()

interface ConnectSocketOptions {
  url: string
  header?: Record<string, any>
  protocols?: string[]
  timeout?: number
  /** 接口调用成功的回调函数 */
  success?: ConnectSocketSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: ConnectSocketFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: ConnectSocketCompleteCallback
}

type ConnectSocketSuccessCallback = (res: GeneralCallbackResult) => void

type ConnectSocketFailCallback = (res: GeneralCallbackResult) => void

type ConnectSocketCompleteCallback = (res: GeneralCallbackResult) => void

export function connectSocket(options: ConnectSocketOptions) {
  const event = "connectSocket"
  const { url } = options

  if (!url || !isString(url)) {
    invokeFailure(event, options, "url cannot be empty")
    return
  }

  if (!/^wss?:\/\//.test(url)) {
    invokeFailure(event, options, "url scheme invalid")
    return
  }

  const prev = weakMainTask.get(main)

  const task = new SocketTask(options)
  invokeSuccess(event, options, {})

  prev && prev.readyState !== prev.CLOSED ? "" : weakMainTask.set(main, task)

  return task
}

interface CloseSocketOptions {
  code?: number
  reason?: string
  /** 接口调用成功的回调函数 */
  success?: CloseSocketSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: CloseSocketFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: CloseSocketCompleteCallback
}

type CloseSocketSuccessCallback = (res: GeneralCallbackResult) => void

type CloseSocketFailCallback = (res: GeneralCallbackResult) => void

type CloseSocketCompleteCallback = (res: GeneralCallbackResult) => void

export function closeSocket<T extends CloseSocketOptions = CloseSocketOptions>(
  options: T
): AsyncReturn<T, CloseSocketOptions> {
  return wrapperAsyncAPI(options => {
    const task = weakMainTask.get(main)
    if (task) {
      task.close(options)
    } else {
      invokeFailure("closeSocket", options, "WebSocketTask is not found")
    }
  }, options)
}

interface SendSocketMessageOptions {
  data: string | ArrayBuffer
  /** 接口调用成功的回调函数 */
  success?: SendSocketMessageSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SendSocketMessageFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SendSocketMessageCompleteCallback
}

type SendSocketMessageSuccessCallback = (res: GeneralCallbackResult) => void

type SendSocketMessageFailCallback = (res: GeneralCallbackResult) => void

type SendSocketMessageCompleteCallback = (res: GeneralCallbackResult) => void

export function sendSocketMessage<T extends SendSocketMessageOptions = SendSocketMessageOptions>(
  options: T
): AsyncReturn<T, SendSocketMessageOptions> {
  return wrapperAsyncAPI(options => {
    const task = weakMainTask.get(main)
    if (task && task.readyState === task.OPEN) {
      task.send(options)
    } else {
      invokeFailure("sendSocketMessage", options, "WebSocket is not connected")
    }
  }, options)
}

const enum EventTypes {
  OPEN = "open",
  CLOSE = "close",
  ERROR = "error",
  MESSAGE = "message"
}

function setMainCallback(callback: Function, type: EventTypes) {
  const cs = (mainEventListener.get(main) as {}) || {}
  cs[type] = callback
  mainEventListener.set(main, cs)
}

interface OnSocketOpenCallbackResult {}

type OnSocketOpenCallback = (result: OnSocketOpenCallbackResult) => void

export function onSocketOpen(callback: OnSocketOpenCallback) {
  setMainCallback(callback, EventTypes.OPEN)
}

interface OnSocketCloseCallbackResult {
  code: number
  reason?: string
}

type OnSocketCloseCallback = (result: OnSocketCloseCallbackResult) => void

export function onSocketClose(callback: OnSocketCloseCallback) {
  setMainCallback(callback, EventTypes.CLOSE)
}

interface OnSocketErrorCallbackResult {
  errMsg: string
}

type OnSocketErrorCallback = (result: OnSocketErrorCallbackResult) => void

export function onSocketError(callback: OnSocketErrorCallback) {
  setMainCallback(callback, EventTypes.ERROR)
}

interface OnSocketMessageCallbackResult {
  data: string | ArrayBuffer
}

type OnSocketMessageCallback = (result: OnSocketMessageCallbackResult) => void

export function OnSocketMessage(callback: OnSocketMessageCallback) {
  setMainCallback(callback, EventTypes.MESSAGE)
}

interface SocketTaskSendOptions {
  data: string | ArrayBuffer
  /** 接口调用成功的回调函数 */
  success?: SocketTaskSendSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SocketTaskSendFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SocketTaskSendCompleteCallback
}

type SocketTaskSendSuccessCallback = (res: GeneralCallbackResult) => void

type SocketTaskSendFailCallback = (res: GeneralCallbackResult) => void

type SocketTaskSendCompleteCallback = (res: GeneralCallbackResult) => void

interface SocketTaskCloseOptions {
  code?: number
  reason?: string
  /** 接口调用成功的回调函数 */
  success?: SocketTaskCloseSuccessCallback
  /** 接口调用失败的回调函数 */
  fail?: SocketTaskCloseFailCallback
  /** 接口调用结束的回调函数（调用成功、失败都会执行）*/
  complete?: SocketTaskCloseCompleteCallback
}

type SocketTaskCloseSuccessCallback = (res: GeneralCallbackResult) => void

type SocketTaskCloseFailCallback = (res: GeneralCallbackResult) => void

type SocketTaskCloseCompleteCallback = (res: GeneralCallbackResult) => void

const enum Methods {
  CONNECT = "connect",
  CLOSE = "close",
  SEND = "send"
}

const taskEventListener = new WeakMap<SocketTask>()

function setTaskCallback(task: SocketTask, callback: Function, type: EventTypes) {
  const cs = (taskEventListener.get(task) as {}) || {}
  cs[type] = callback
  taskEventListener.set(task, cs)
}

let incSocketTaskId = 0

const tasks = new Map<number, SocketTask>()

export class SocketTask {
  readonly socketTaskId = incSocketTaskId++

  /** @internal */
  _readyState: number = 0

  readonly CONNECTING: number = 0

  readonly OPEN: number = 1

  readonly CLOSING: number = 2

  readonly CLOSED: number = 3

  constructor(options: ConnectSocketOptions) {
    tasks.set(this.socketTaskId, this)

    let { header = {} } = options
    header = headerValueToString(header)

    this.operate(Methods.CONNECT, extend({ timeout: 0 }, options, { header }))
  }

  get readyState() {
    return this._readyState
  }

  private operate(method: Methods, data: Record<string, any>) {
    InnerJSBridge.invoke(
      "operateWebSocket",
      { socketTaskId: this.socketTaskId, method, data },
      result => {
        const event = `SocketTask.${method}`
        invokeCallback(event, data, result)
      }
    )
  }

  close(options: SocketTaskCloseOptions) {
    this.operate(Methods.CLOSE, extend({ code: 1000 }, options))
  }

  send(options: SocketTaskSendOptions) {
    if (this.readyState !== this.OPEN) {
      invokeFailure("SocketTask.send", options, "readyState is not OPEN")
      return
    }

    const opts = extend({}, options) as any
    if (isArrayBuffer(options.data)) {
      opts.__arrayBuffer__ = globalThis.__ArrayBufferRegister.set(opts.data)
    } else if (isString(options.data)) {
      opts.string = options.data
    } else {
      invokeFailure("SocketTask.send", options, "data must be a string or ArrayBuffer")
      return
    }
    delete opts.data
    this.operate(Methods.SEND, opts)
  }

  onOpen(callback: (res: OnSocketOpenCallbackResult) => void) {
    setTaskCallback(this, callback, EventTypes.OPEN)
  }

  onClose(callback: (res: OnSocketCloseCallbackResult) => void) {
    setTaskCallback(this, callback, EventTypes.CLOSE)
  }

  onError(callback: (res: OnSocketErrorCallbackResult) => void) {
    setTaskCallback(this, callback, EventTypes.ERROR)
  }

  onMessage(callback: (res: OnSocketMessageCallbackResult) => void) {
    setTaskCallback(this, callback, EventTypes.MESSAGE)
  }
}

function invokeEventListener(task: SocketTask, type: EventTypes, data: any) {
  const cs = taskEventListener.get(task)
  if (cs) {
    const fn = cs[type]
    isFunction(fn) && fn(data)
  }

  const mainTask = weakMainTask.get(main)
  if (mainTask && mainTask.socketTaskId === task.socketTaskId) {
    const cs = mainEventListener.get(main)
    if (cs) {
      const fn = cs[type]
      isFunction(fn) && fn(data)
    }
  }
}

const enum SubscribeKeys {
  ON_OPEN = "ON_OPEN",
  ON_CLOSE = "ON_CLOSE",
  ON_ERROR = "ON_ERROR",
  ON_MESSAGE = "ON_MESSAGE"
}

const key = (k: string) => "MODULE_WEB_SOCKET_" + k

InnerJSBridge.subscribe<{ socketTaskId: number }>(key(SubscribeKeys.ON_OPEN), data => {
  const task = tasks.get(data.socketTaskId)
  if (task) {
    task._readyState = task.OPEN
    invokeEventListener(task, EventTypes.OPEN, data)
  }
})

function destroy(task: SocketTask, type: EventTypes, data: any) {
  task._readyState = task.CLOSED
  invokeEventListener(task, type, data)
  tasks.delete(data.socketTaskId)
  taskEventListener.delete(task)

  const mainTask = weakMainTask.get(main)
  if (mainTask && mainTask.socketTaskId === task.socketTaskId) {
    mainEventListener.delete(main)
  }
}

InnerJSBridge.subscribe<{ socketTaskId: number }>(key(SubscribeKeys.ON_CLOSE), data => {
  const task = tasks.get(data.socketTaskId)
  task && destroy(task, EventTypes.CLOSE, data)
})

InnerJSBridge.subscribe<{ socketTaskId: number }>(key(SubscribeKeys.ON_ERROR), data => {
  const task = tasks.get(data.socketTaskId)
  task && destroy(task, EventTypes.ERROR, data)
})

InnerJSBridge.subscribe<{ socketTaskId: number; data: string | ArrayBuffer }>(
  key(SubscribeKeys.ON_MESSAGE),
  data => {
    const task = tasks.get(data.socketTaskId)
    fetchArrayBuffer(data, "data")
    task && invokeEventListener(task, EventTypes.MESSAGE, data)
  }
)
