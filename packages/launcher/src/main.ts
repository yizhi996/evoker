import { createApp } from "evoker"
import { createPinia } from "pinia"

import App from "./App.vue"

import "./tailwind.css"

ek.hideCapsule()

const app = createApp(App)

const pinia = createPinia()
app.use(pinia)

app.mount("#app")
