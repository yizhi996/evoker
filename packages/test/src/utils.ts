interface Callback {
  callback: Function
  once: boolean
}

const events = new Map<string, Callback[]>()

export function on(name: string, callback: Function) {
  const list = events.get(name) || []
  list.push({ callback, once: false })
  events.set(name, list)
}

export function once(name: string, callback: Function) {
  const list = events.get(name) || []
  list.push({ callback, once: true })
  events.set(name, list)
}

export function off(name: string, callback: Function) {
  const list = events.get(name) || []
  const i = list.findIndex(c => c.callback === callback)
  if (i > -1) {
    list.splice(i, 1)
  }
  events.set(name, list)
}

export function dispatch(name: string, data: any) {
  const list = events.get(name) || []

  list.forEach(c => {
    c.callback(data)
    if (c.once) {
      off(name, c.callback)
    }
  })
}
