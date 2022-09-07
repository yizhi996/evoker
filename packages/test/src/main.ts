import { createApp } from "evoker"
import App from "./App.vue"
import TaskBoard from "./components/TaskBoard.vue"

const app = createApp(App)

app.component("TaskBoard", TaskBoard)

app.mount("#app")
