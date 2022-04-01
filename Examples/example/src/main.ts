import { createApp } from "nzoth"
import App from "./App.vue"
import { CellGroup, Cell } from "vant"
import NTopic from "./components/NTopic.vue"
import NCellGroup from "./components/NCellGroup.vue"
import NCell from "./components/NCell.vue"

import "./tailwind.css"

const app = createApp(App)

app.config.errorHandler = (err, vm, info) => {
  console.log(err, vm, info)
}

app.config.warnHandler = (msg, vm, trace) => {
  console.log(msg, vm, trace)
}

/** @ts-ignore */
app.use(CellGroup).use(Cell)

app.component("n-topic", NTopic)
app.component("n-cell", NCell)
app.component("n-cell-group", NCellGroup)

app.mount("#app")
