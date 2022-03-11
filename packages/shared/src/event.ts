type EventListener = (data: any) => void

interface Event {
  id: number
  listener: EventListener
}

let index = 0
const events: Record<string, Event[]> = {}

export function on(type: string, listener: EventListener) {
  events[type] === undefined && (events[type] = [])
  const id = index
  events[type].push({ id, listener })
  index += 1
  return id
}

export function off(type: string, id: number) {
  if (events[type]) {
    const idx = events[type].findIndex(item => {
      return item.id === id
    })
    if (idx > -1) {
      events[type].splice(idx, 1)
    }
  }
}

export function dispatch(type: string, data: any) {
  if (events[type]) {
    events[type].forEach(evt => {
      evt.listener(data)
    })
  }
}
