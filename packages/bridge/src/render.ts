import { publish, subscribe } from "./bridge"

const Method = "vSync"

class Pipeline {
  sync(messages: any[], pageId: number) {
    publish(Method, messages, pageId)
  }

  onSync(callback: (message: any[]) => void) {
    subscribe(Method, callback)
  }
}

export const pipeline = new Pipeline()
