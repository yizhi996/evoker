import { publish, subscribe } from "./bridge"
import { queuePostFlushCb } from "vue"

const Method = "vdSync"

const queues = new Map<number, any[]>()

const jobs = new Map<number, any>()

function flush(pageId: number) {
  const messages = queues.get(pageId)
  publish(Method, messages, pageId)
  queues.delete(pageId)
  jobs.delete(pageId)
}

export function sync(message: any, pageId: number) {
  const messages = queues.get(pageId)
  if (messages) {
    messages.push(message)
  } else {
    queues.set(pageId, [message])
  }

  let job = jobs.get(pageId)
  if (!job) {
    job = flush.bind(null, pageId)
    jobs.set(pageId, job)
  }
  queuePostFlushCb(job)
}

export function onSync(callback: (messages: any[]) => void) {
  subscribe(Method, callback)
}
