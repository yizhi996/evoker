import ws from "ws"
import { isString, isFunction } from "@nzoth/shared"

let websocketServer: ws.Server

interface RunWssOptions {
  host?: string | boolean
  port?: number
  onConnect?: (client: ws) => void
  onDisconnect?: (code?: number) => void
  onRecv?: (message: string) => void
}

export function runWebSocketServer(options: RunWssOptions) {
  let host = "127.0.0.1"
  if (options.host) {
    if (isString(options.host) && options.host.length) {
      host = options.host
    } else {
      host = "0.0.0.0"
    }
  }
  const port = options.port || 8800

  console.log(`[NZoth devServer] run: ${host}:${port}`)

  websocketServer = new ws.Server({
    host: host,
    port: port
  })

  websocketServer.on("connection", client => {
    console.log("\n[NZoth devServer] client connected")

    isFunction(options.onConnect) && options.onConnect(client)

    client.on("close", ws => {
      console.log("[NZoth devServer] client close connection", ws)
      isFunction(options.onDisconnect) && options.onDisconnect(ws)
    })

    client.on("error", error => {
      console.log("NZoth devServer] client connection error", error)
      isFunction(options.onDisconnect) && options.onDisconnect()
    })

    client.on("message", (message: string) => {
      isFunction(options.onRecv) && options.onRecv(message)
    })
  })

  websocketServer.on("error", error => {
    console.warn(`NZoth devServer] error: ${error}`)
  })
}

export function createMessage(header: string, data: any) {
  const result = Buffer.alloc(64)
  result.write(header)
  const body = isString(data) ? Buffer.from(data, "utf-8") : data
  return Buffer.concat([result, body])
}

export function createFileMessage(
  appId: string,
  packageName: string,
  data: Buffer
) {
  return createMessage(`${appId}---${packageName}`, data)
}
