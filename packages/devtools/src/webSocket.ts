import {
  DevtoolsBridgeCommands,
  DevtoolsBridgeExecEvents,
  InvokeArgs,
  PublishArgs
} from "@evoker/shared"

function createWebSocketClient(port: number = 33233) {
  const client = new window.WebSocket(`ws://127.0.0.1:${port}`)
  client.onopen = () => {
    console.log("connected")
    if (globalThis.__Config.env === "webview") {
      client.send(JSON.stringify({ command: "SET_PAGE_ID", args: globalThis.__Config.webViewId }))
    } else {
      client.send(JSON.stringify({ command: "SET_APP_SERVICE", args: "" }))
    }
  }

  client.onerror = err => {
    console.log(err)
  }

  client.onmessage = message => {
    try {
      const { exec, args, result } = JSON.parse(message.data.toString()) as {
        exec: DevtoolsBridgeExecEvents
        args: PublishArgs
        result: string
      }
      if (exec === DevtoolsBridgeExecEvents.SUBSCRIBE_HANDLER) {
        const { event, params, webViewId } = args as PublishArgs
        JSBridge.subscribeHandler(event, JSON.parse(params), webViewId)
      } else if (exec === DevtoolsBridgeExecEvents.INVOKE_CALLBACK) {
        JSBridge.invokeCallbackHandler(JSON.parse(result))
      }
    } catch {}
  }

  return client
}

const client = createWebSocketClient()

function send(message: string) {
  client.readyState === client.OPEN && client.send(message)
}

export function invokeHandler(command: DevtoolsBridgeCommands, args: InvokeArgs) {
  const message = JSON.stringify({ command, args })
  send(message)
}

export function publishHandler(command: DevtoolsBridgeCommands, args: PublishArgs) {
  const message = JSON.stringify({ command, args })
  send(message)
}
