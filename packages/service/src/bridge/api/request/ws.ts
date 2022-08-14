import { GeneralCallbackResult, invokeCallback, invokeFailure, invokeSuccess } from "@evoker/bridge"
import { InnerJSBridge } from "../../bridge"
import { extend, isFunction, isString } from "@vue/shared"
import { headerValueToString } from "./util"
import { addEvent, dispatchEvent, removeEvent } from "@evoker/shared"

interface ConnectSocketOptions {
  url: string
  header?: Record<string, any>
  protocols?: string[]
  timeout?: number
  success?: ConnectSocketSuccessCallback
  fail?: ConnectSocketFailCallback
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

  let task = new SocketTask(options)
  invokeSuccess(event, options, {})

  return task
}

interface OnSocketOpenCallbackResult {}

type OnSocketOpenCallback = (result: OnSocketOpenCallbackResult) => void

let onSocketOpenCallback: OnSocketOpenCallback

export function onSocketOpen(callback: OnSocketOpenCallback) {
  onSocketOpenCallback = callback
}

interface OnSocketCloseCallbackResult {
  code: number
  reason?: string
}

type OnSocketCloseCallback = (result: OnSocketCloseCallbackResult) => void

let onSocketCloseCallback: OnSocketCloseCallback

export function onSocketClose(callback: OnSocketCloseCallback) {
  onSocketCloseCallback = callback
}

interface OnSocketErrorCallbackResult {
  errMsg: string
}

type OnSocketErrorCallback = (result: OnSocketErrorCallbackResult) => void

let onSocketErrorCallback: OnSocketErrorCallback

export function onSocketError(callback: OnSocketErrorCallback) {
  onSocketErrorCallback = callback
}

interface OnSocketMessageCallbackResult {
  data: string | ArrayBuffer
}

type OnSocketMessageCallback = (result: OnSocketMessageCallbackResult) => void

let onSocketMessageCallback: OnSocketMessageCallback

export function OnSocketMessage(callback: OnSocketMessageCallback) {
  onSocketMessageCallback = callback
}

interface SocketTaskSendOptions {
  data: string | ArrayBuffer
  success?: SocketTaskSendSuccessCallback
  fail?: SocketTaskSendFailCallback
  complete?: SocketTaskSendCompleteCallback
}

type SocketTaskSendSuccessCallback = (res: GeneralCallbackResult) => void

type SocketTaskSendFailCallback = (res: GeneralCallbackResult) => void

type SocketTaskSendCompleteCallback = (res: GeneralCallbackResult) => void

interface SocketTaskCloseOptions {
  code?: number
  reason?: string
  success?: SocketTaskCloseSuccessCallback
  fail?: SocketTaskCloseFailCallback
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

export class SocketTask {
  private socketTaskId: number

  private _readyState: number = 0

  private onSocketOpenCallback: OnSocketOpenCallback | null = null

  private onSocketCloseCallback: OnSocketCloseCallback | null = null

  private onSocketErrorCallback: OnSocketErrorCallback | null = null

  private onSocketMessageCallback: OnSocketMessageCallback | null = null

  readonly CONNECTING: number = 0

  readonly OPEN: number = 1

  readonly CLOSING: number = 2

  readonly CLOSED: number = 3

  constructor(options: ConnectSocketOptions) {
    const { socketTaskId, onOpen, onClose, onError, onMessage } = useWebSocket()

    this.socketTaskId = socketTaskId

    onOpen(data => {
      this._readyState = this.OPEN
      isFunction(this.onSocketOpenCallback) && this.onSocketOpenCallback(data)
    })

    onClose(data => {
      this._readyState = this.CLOSED
      isFunction(this.onSocketCloseCallback) && this.onSocketCloseCallback(data)
    })

    onError(data => {
      isFunction(this.onSocketErrorCallback) && this.onSocketErrorCallback(data)
    })

    onMessage(data => {
      isFunction(this.onSocketMessageCallback) && this.onSocketMessageCallback(data)
    })

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
      invokeFailure("SocketTask.send", options, "readyState is not equal to OPEN")
      return
    }
    let opts = extend({}, options) as any
    if (isString(options.data)) {
      opts.text = options.data
      delete opts.data
    }
    this.operate(Methods.SEND, opts)
  }

  onOpen(callback: (res: OnSocketOpenCallbackResult) => void) {
    this.onSocketOpenCallback = callback
  }

  onClose(callback: (res: OnSocketCloseCallbackResult) => void) {
    this.onSocketCloseCallback = callback
  }

  onError(callback: (res: OnSocketErrorCallbackResult) => void) {
    this.onSocketErrorCallback = callback
  }

  onMessage(callback: (res: OnSocketMessageCallbackResult) => void) {
    this.onSocketMessageCallback = callback
  }
}

enum SubscribeKeys {
  ON_OPEN = "MODULE_WEB_SOCKET_ON_OPEN",
  ON_CLOSE = "MODULE_WEB_SOCKET_ON_CLOSE",
  ON_ERROR = "MODULE_WEB_SOCKET_ON_ERROR",
  ON_MESSAGE = "MODULE_WEB_SOCKET_ON_MESSAGE"
}

Object.values(SubscribeKeys).forEach(key => {
  InnerJSBridge.subscribe(key, data => {
    dispatchEvent(key, data)
  })
})

let incSocketTaskId = 0

function useWebSocket() {
  const socketTaskId = incSocketTaskId++

  const eventListener = new Map<string, number>()

  const createListener = (key: SubscribeKeys, callback: (data: any) => void) => {
    const prev = eventListener.get(key)
    prev && removeEvent(key, prev)
    const id = addEvent<{ socketTaskId: number }>(key, data => {
      if (data.socketTaskId === socketTaskId) {
        callback(data)
      }
    })
    eventListener.set(key, id)
  }

  const onOpen = (callback: (res: OnSocketOpenCallbackResult) => void) => {
    createListener(SubscribeKeys.ON_OPEN, data => {
      callback(data)
      isFunction(onSocketOpenCallback) && onSocketOpenCallback(data)
    })
  }

  const onClose = (callback: (res: OnSocketCloseCallbackResult) => void) => {
    createListener(SubscribeKeys.ON_CLOSE, data => {
      callback(data)
      isFunction(onSocketCloseCallback) && onSocketCloseCallback(data)
    })
  }

  const onError = (callback: (res: OnSocketErrorCallbackResult) => void) => {
    createListener(SubscribeKeys.ON_ERROR, data => {
      callback(data)
      isFunction(onSocketErrorCallback) && onSocketErrorCallback(data)
    })
  }

  const onMessage = (callback: (res: OnSocketMessageCallbackResult) => void) => {
    createListener(SubscribeKeys.ON_MESSAGE, data => {
      callback(data)
      isFunction(onSocketMessageCallback) && onSocketMessageCallback(data)
    })
  }

  return {
    socketTaskId,
    onOpen,
    onClose,
    onError,
    onMessage
  }
}
