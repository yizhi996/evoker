import ws from "ws"
import { isString, isFunction } from "@vue/shared"

let websocketServer: ws.Server

export type Client = ws & { _id: number }

interface RunWssOptions {
  host?: string | boolean
  port?: number
  onConnect?: (client: Client) => void
  onDisconnect?: (client: Client) => void
  onRecv?: (client: Client, message: string) => void
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

  websocketServer.on("connection", (client: Client) => {
    console.log("\n[NZoth devServer] client connected")

    client._id = Date.now()

    isFunction(options.onConnect) && options.onConnect(client)

    client.on("close", () => {
      console.log("[NZoth devServer] client close connection")
      isFunction(options.onDisconnect) && options.onDisconnect(client)
    })

    client.on("error", error => {
      console.log("NZoth devServer] client connection error", error)
      isFunction(options.onDisconnect) && options.onDisconnect(client)
    })

    client.on("message", (message: string) => {
      options.onRecv && options.onRecv(client, message)
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

export function createFileMessage(appId: string, packageName: string, data: Buffer) {
  return createMessage(`${appId}---${packageName}`, data)
}
