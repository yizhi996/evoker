<template>
  <n-cell-group class="m-2.5">
    <n-cell title="address">
      <input class="w-full bg-white" v-model:value="address" />
    </n-cell>
    <n-cell title="text">
      <input class="w-full bg-white" v-model:value="inputValue" />
    </n-cell>
  </n-cell-group>
  <button v-if="!isConnected" type="primary" @click="connect">Connect</button>
  <button v-else type="danger" @click="close">Close</button>
  <button type="primary" @click="send(inputValue)" :disabled="!isConnected">Send</button>

  <n-topic>Messages</n-topic>
  <scroll-view class="w-full h-80 bg-gray-200" scroll-y>
    <div
      class="w-full flex items-center bg-white px-3"
      v-for="msg of messages"
      :key="msg.timestamp"
    >
      <span v-if="msg.flag" class="text-green-400 text-sm">↓</span>
      <span v-else class="text-red-400 text-sm">↑</span>
      <div class="ml-3 w-full flex justify-between">
        <span>text: {{ msg.text }}</span>
        <span>{{ msg.timestamp }}</span>
      </div>
    </div>
  </scroll-view>
</template>

<script setup lang="ts">
import { onUnmounted, ref } from "vue"

const address = ref("wss://evokerdev.com/echo")

const inputValue = ref("在吗？")

const isConnected = ref(false)

const enum Flag {
  SEND = 0,
  RECV = 1
}

interface Message {
  text: string
  flag: Flag
  timestamp: number
}

const messages = ref<Message[]>([])

let ws: ReturnType<typeof ek.connectSocket> = null

const connect = () => {
  ws = ek.connectSocket({ url: address.value })
  ws.onOpen(() => {
    isConnected.value = true
    messages.value = []
    send("ping")
  })
  ws.onClose(() => {
    isConnected.value = false
  })
  ws.onError(({ errMsg }) => {
    isConnected.value = false
    ek.showToast({ title: errMsg, icon: "none" })
  })
  ws.onMessage(({ data }) => {
    messages.value.unshift({ text: data, flag: Flag.RECV, timestamp: Date.now() })
  })
}

const send = (text: string) => {
  if (ws && ws.readyState === ws.OPEN) {
    ws.send({ data: text })
    messages.value.unshift({ text, flag: Flag.SEND, timestamp: Date.now() })
  }
}

const close = () => {
  ws?.close()
}

onUnmounted(() => {
  close()
})
</script>
