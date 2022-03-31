type Callback = (...args: any[]) => void

const events: Record<string, Callback[]> = {}

export function onEvent(type: string, callback: Callback) {
  events[type] === undefined && (events[type] = [])
  events[type].push(callback)
}

export function offEvent(type: string, callback: Callback) {
  if (events[type]) {
    const idx = events[type].indexOf(callback)
    if (idx > -1) {
      events[type].splice(idx, 1)
    }
  }
}

export function emitEvent(type: string, data: any) {
  if (events[type]) {
    events[type].forEach(cb => {
      cb(data)
    })
  }
}
