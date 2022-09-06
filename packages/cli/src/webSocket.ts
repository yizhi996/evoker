import ws from "ws"
import { isString, isFunction } from "@vue/shared"

const log = msg => console.log(`[Evoker devServer] ${msg}`)

const warn = msg => console.warn(`[Evoker devServer] ${msg}`)

export type Client = ws & { _id: number }

const enum HeartBeatMessage {
  PING = "ping",
  PONG = "pong"
}

interface CreateWebSockerServerOptions {
  host?: string | boolean
  port?: number
  onConnect?: (client: Client) => void
  onDisconnect?: (client: Client) => void
  onRecv?: (client: Client, message: string) => void
}

export function createWebSocketServer(options: CreateWebSockerServerOptions) {
  let host = "127.0.0.1"

  if (options.host) {
    if (isString(options.host) && options.host.length) {
      host = options.host
    } else {
      host = "0.0.0.0"
    }
  }

  let port = options.port ?? 5173

  log(`run: ${host}:${port}`)

  let webSocketServer = new ws.WebSocketServer({ host, port })

  webSocketServer.on("connection", (client: Client) => {
    console.log()
    log("client connected")

    isFunction(options.onConnect) && options.onConnect(client)

    client.on("close", () => {
      log("client close connection")
      isFunction(options.onDisconnect) && options.onDisconnect(client)
    })

    client.on("error", error => {
      warn(`client connection error: ${error}`)
      isFunction(options.onDisconnect) && options.onDisconnect(client)
    })

    client.on("message", (message: string) => {
      if (message === HeartBeatMessage.PING) {
        client.send(HeartBeatMessage.PONG)
      } else {
        options.onRecv && options.onRecv(client, message)
      }
    })
  })

  webSocketServer.on("error", (error: Error & { code?: string }) => {
    if (error.code === "EADDRINUSE") {
      log(`port: ${port} is already in use`)
      webSocketServer = new ws.WebSocketServer({ host, port: ++port })
      log(`run: ${host}:${port}`)
    } else {
      warn(`error: ${error}`)
    }
  })

  return {
    wss: webSocketServer,
    clients: () => Array.from(webSocketServer.clients)
  }
}

export function createMessage(header: string, data: any) {
  const result = Buffer.alloc(64)
  result.write(header)
  const body = isString(data) ? Buffer.from(data, "utf-8") : data
  return Buffer.concat([result, body])
}

export function createFileMessage(
  appId: string,
  version: string,
  packageName: string,
  data: Buffer
) {
  return createMessage(`${appId}---${version}---${packageName}`, data)
}
