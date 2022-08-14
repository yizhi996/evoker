import { isFunction } from "@vue/shared"
import { isNumber } from "./index"

type Callback<T> = (res: T) => void

interface Event<T> {
  id: number
  callback: Callback<T>
}

let index = 0

const events: Record<string, Event<any>[]> = {}

export function addEvent<T = unknown>(type: string, callback: Callback<T>) {
  const id = ++index
  events[type] === undefined && (events[type] = [])
  events[type].push({ id, callback })
  return id
}

export function removeEvent<T = unknown>(type: string, callback: number | Callback<T>) {
  if (events[type]) {
    let idx = -1
    if (isNumber(callback)) {
      idx = events[type].findIndex(ev => ev.id === callback)
    } else if (isFunction(callback)) {
      idx = events[type].findIndex(ev => ev.callback === callback)
    }
    idx > -1 && events[type].splice(idx, 1)
  }
}

export function dispatchEvent(type: string, data?: any) {
  if (events[type]) {
    events[type].forEach(ev => {
      ev.callback(data)
    })
  }
}
