import {
  GeneralCallbackResult,
  invokeCallback,
  InvokeCallbackResult,
  invokeFailure,
  invokeSuccess
} from "@evoker/bridge"
import { InnerJSBridge } from "../../bridge"
import { extend, isString } from "@vue/shared"
import { headerValueToString } from "./util"
import { addEvent, dispatchEvent, removeEvent } from "@evoker/shared"

let socketTaskId = 0

const socketTasks = new Map<number, SocketTask>()

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
  return new SocketTask(options)
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
  private id: number

  private options: ConnectSocketOptions

  private eventListener = new Map<string, number>()

  private _readyState: number = 0

  readonly CONNECTING: number = 0

  readonly OPEN: number = 1

  readonly CLOSING: number = 2

  readonly CLOSED: number = 3

  constructor(options: ConnectSocketOptions) {
    this.id = socketTaskId++
    this.options = options
    socketTasks.set(this.id, this)

    this.connect()
  }

  get readyState() {
    return this._readyState
  }

  private operate(
    method: Methods,
    data: Record<string, any>,
    before?: (res: InvokeCallbackResult<unknown>) => void,
    after?: () => void
  ) {
    InnerJSBridge.invoke("operateWebSocket", { socketTaskId: this.id, method, data }, result => {
      const event = `socketTask${method.charAt(0).toUpperCase() + method.slice(1)}`
      before && before(result)
      invokeCallback(event, data, result)
      after && after()
    })
  }

  private connect() {
    let { url, header = {} } = this.options

    if (!url || !isString(url)) {
      invokeFailure("socketTaskOpen", this.options, "url cannot be empty")
      return
    }

    if (!/^wss?:\/\//.test(url)) {
      invokeFailure("socketTaskOpen", this.options, "url scheme invalid, need ws://")
      return
    }

    header = headerValueToString(header)

    this.operate(Methods.CONNECT, { ...this.options, timeout: 0, header }, result => {
      if (result.errMsg) {
        this._readyState = this.CONNECTING
      } else {
        this._readyState = this.OPEN
      }
    })
  }

  close(options: SocketTaskCloseOptions) {
    this._readyState = this.CLOSING
    this.operate(Methods.CLOSE, extend({ code: 1000 }, options), result => {
      if (result.errMsg) {
        this._readyState = this.OPEN
      } else {
        this._readyState = this.CLOSED
      }
    })
  }

  send(options: SocketTaskSendOptions) {
    let opts = extend({}, options) as any
    if (isString(options.data)) {
      opts.text = options.data
      delete opts.data
    }
    this.operate(Methods.SEND, opts)
  }

  private createListener(key: SubscribeKeys, callback: (data: any) => void) {
    const prev = this.eventListener.get(key)
    prev && removeEvent(key, prev)
    const id = addEvent<{ socketTaskId: number }>(key, data => {
      if (data.socketTaskId === this.id) {
        callback(data)
      }
    })
    this.eventListener.set(key, id)
  }

  onOpen(callback: (res: any) => void) {
    this.createListener(SubscribeKeys.ON_OPEN, callback)
  }

  onClose(callback: (res: { code: number; reason: string }) => void) {
    this.createListener(SubscribeKeys.ON_CLOSE, callback)
  }

  onError(callback: (res: { errMsg: string }) => void) {
    this.createListener(SubscribeKeys.ON_ERROR, callback)
  }

  onMessage(callback: (res: { data: string | ArrayBuffer }) => void) {
    this.createListener(SubscribeKeys.ON_MESSAGE, callback)
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
