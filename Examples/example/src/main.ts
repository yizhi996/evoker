import { createApp } from "nzoth"
import App from "./App.vue"
import config from "./app.json"
import { CellGroup, Cell } from "vant"

import "./tailwind.css"
;(globalThis as any).__NZConfig = config

const app = createApp(App)

app.config.errorHandler = (err, vm, info) => {
  console.log(err, vm, info)
  nz.report({ level: "error", module: "NZoth_JS_SDK", message: info })
}

app.config.warnHandler = (msg, vm, trace) => {
  console.log(msg, vm, trace)
  nz.report({ level: "warn", module: "NZoth_JS_SDK", message: msg })
}

app.use(CellGroup).use(Cell)

app.mount("#app")
