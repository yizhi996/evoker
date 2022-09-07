import { isArray, isString } from "@vue/shared"
import { ref, Ref, isRef } from "vue"
import isEqual from "lodash.isequal"

type Factory = (context: Context) => void

const enum State {
  WAITING = 0,
  RUNNING,
  SUCCESSFULLY,
  FAILURE
}

export interface Task {
  name: string
  state: State
  factory: Factory
  tests: Test[]
}

interface Test {
  name: string
  id: number
  state: State
  factory: Factory
  startAt: number
  endAt: number
  error?: string
  timeout: number
}

class Context {
  task: Task

  private queue: number[] = []

  private waitQueue: number[] = []

  private currentTestId: number = 0

  constructor(task: Task) {
    this.task = task
  }

  test(name: string, factory: Factory, timeout: number = 0) {
    const id = this.task.tests.length
    const test = { name, id, factory, state: State.WAITING, startAt: 0, endAt: 0, timeout }
    this.task.tests.push(test)

    if (this.queue.length) {
      this.waitQueue.push(id)
    } else {
      this.exec(id)
    }
  }

  expect<T>(test: T) {
    const assertion = new Assertion(this, test)
    setTimeout(() => {
      const i = this.queue.indexOf(this.currentTestId)
      if (i > -1) {
        this.queue.splice(i, 1)
      }
      const next = this.waitQueue.shift()
      if (next) {
        this.exec(next)
      }
    })
    return assertion
  }

  private exec(id: number) {
    this.queue.push(id)
    this.currentTestId = id
    const test = this.task.tests[id]

    let that = this
    function work() {
      test.state = State.RUNNING
      test.startAt = Date.now()
      test.factory(that)
    }

    if (test.timeout > 0) {
      setTimeout(work, test.timeout)
    } else {
      work()
    }
  }
}

class Assertion<T = any> {
  private object?: T

  private reversal: boolean

  private context: Context

  not!: Assertion

  constructor(context: Context, object: T, reversal: boolean = false) {
    this.context = context
    this.object = object
    this.reversal = reversal

    if (!reversal) {
      this.not = new Assertion(context, object, true)
    }
  }

  assert(equal: boolean, expected: unknown) {
    const e = this.reversal ? !equal : equal
    const test = this.context.task.tests.find(t => t.state === State.RUNNING)
    if (test) {
      if (e) {
        test.state = State.SUCCESSFULLY
      } else {
        test.state = State.FAILURE
        test.error = `must be ${expected}, received ${this.object}`
      }
      test.endAt = Date.now()
    }

    if (!this.context.task.tests.find(t => t.state === State.WAITING)) {
      let state = State.SUCCESSFULLY
      for (const t of this.context.task.tests) {
        if (t.state !== State.SUCCESSFULLY) {
          state = State.FAILURE
        }
      }
      this.context.task.state = state
    }
  }

  toBe(expected: T) {
    const equal = this.object === expected
    this.assert(equal, expected)
  }

  toBeNull() {
    this.assert(this.object === null, "null")
  }

  toEqual(expected: T) {
    this.assert(isEqual(expected, this.object), expected)
  }

  toContain<E>(item: E) {
    let contain = false
    if (isString(item) && isString(this.object)) {
      contain = this.object.includes(item)
    } else if (item && isArray(this.object)) {
      contain = this.object.includes(item)
    }
    this.assert(contain, item)
  }
}

export function describe(name: string, factory: Factory): Ref<Task> {
  return ref({ name, state: State.WAITING, factory, tests: [] })
}

export function run(task: Task | Ref<Task>) {
  const raw = isRef(task) ? task.value : task
  raw.state = State.RUNNING
  const ctx = new Context(raw)
  raw.factory(ctx)
}
