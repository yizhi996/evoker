import { invokeHandler, publishHandler } from "./webSocket"
import TouchEmulator from "hammer-touchemulator"

export { invokeHandler, publishHandler }

if (globalThis.__Config.env === "webview") {
  TouchEmulator()
  TouchEmulator.ignoreTags = []
}
