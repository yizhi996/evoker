import { isArray, isPromise, isString } from "@vue/shared"
import { ref } from "vue"

type Factory = (context: Context) => void

const enum State {
  WAITING = 0,
  RUNNING,
  SUCCESSFULLY,
  FAILURE
}

interface Task {
  id: number
  name: string
  state: State
  fn: Factory
  tasks: Task[]
  startAt: number
  endAt: number
}

export const tasks = ref<Task[]>([])

let incTaskId = 0

class Context {
  task: Task

  queue: number[] = []

  waitQueue: number[] = []

  incTestId = 0

  constructor(task: Task) {
    this.task = task
  }

  test(name: string, fn: Factory) {
    const id = this.task.tasks.length
    const test = { id, name, fn, state: State.WAITING, tasks: [], startAt: 0, endAt: 0 }
    this.task.tasks.push(test)

    const exec = async (id: number) => {
      this.queue.push(id)
      const sub = this.task.tasks[id]
      sub.state = State.RUNNING
      sub.startAt = Date.now()
      await sub.fn(this)

      const i = this.queue.indexOf(id)
      if (i > -1) {
        this.queue.splice(i, 1)
      }
      const next = this.waitQueue.shift()
      if (next) {
        exec(next)
      }
    }

    if (this.queue.length) {
      this.waitQueue.push(id)
    } else {
      exec(id)
    }
  }

  expect<T>(test: T) {
    return new Assertion(this, test)
  }
}

export function describe(name: string, factory: Factory) {
  const id = incTaskId++
  const task = { id, name, state: State.WAITING, fn: factory, tasks: [], startAt: 0, endAt: 0 }
  tasks.value.push(task)
}

export function run() {
  for (const task of tasks.value) {
    task.state = State.RUNNING
    const ctx = new Context(task)
    task.fn(ctx)
  }
}

class Assertion<T = any> {
  private object?: T

  private toggle: boolean

  private context: Context

  not!: Assertion

  constructor(context: Context, object: T, toggle: boolean = false) {
    this.context = context
    this.object = object
    this.toggle = toggle

    if (!toggle) {
      this.not = new Assertion(context, object, true)
    }
  }

  assert(equal: boolean) {
    const e = this.toggle ? !equal : equal
    const task = this.context.task.tasks.find(t => t.state === State.RUNNING)
    if (task) {
      task.state = e ? State.SUCCESSFULLY : State.FAILURE
      task.endAt = Date.now()
    }

    if (!this.context.task.tasks.find(t => t.state === State.WAITING)) {
      let state = State.SUCCESSFULLY
      for (const t of this.context.task.tasks) {
        if (t.state !== State.SUCCESSFULLY) {
          state = State.FAILURE
        }
      }
      this.context.task.state = state
    }
  }

  toBe(expected: T) {
    const equal = this.object === expected
    this.assert(equal)
  }

  toBeNull() {
    this.assert(this.object === null)
  }

  toEqual(expected: T) {
    if (isArray(expected) && isArray(this.object)) {
      this.assert(arrayEqual(this.object, expected))
    }
  }

  toContain<E>(item: E) {
    let contain = false
    if (isString(item) && isString(this.object)) {
      contain = this.object.includes(item)
    } else if (item && isArray(this.object)) {
      contain = this.object.includes(item)
    }
    return this.assert(contain)
  }
}

function arrayEqual(a: any[], b: any[]) {
  if (a.length === 0 && b.length === 0) {
    return true
  }
  if (a.length !== b.length) {
    return false
  }

  let equal = true
  for (let i = 0; i < a.length; i++) {
    const aa = [i]
    if (aa !== b[i]) {
      return false
    }
  }
  return equal
}
