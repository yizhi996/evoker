import { getCurrentWebViewId } from "../../../app"
import { SyncFlags } from "@evoker/shared"
import { isFunction } from "@vue/shared"
import { randomId } from "../../../utils"
import { sync } from "@evoker/bridge"
import { createVideoContextInstance } from "../media/video"

const selectorQueryCallbacks = new Map<string, Function>()

export function invokeSelectorQuery(data: any[]) {
  const [_, id, list] = data as [SyncFlags, string, any[]]
  const callback = selectorQueryCallbacks.get(id)
  if (isFunction(callback)) {
    callback(list)
    selectorQueryCallbacks.delete(id)
  }
}

interface SelectorQueryQueue {
  selector: string
  single: boolean
  fields: NodeFields
}

class SelectorQuery {
  private queue: SelectorQueryQueue[] = []

  private queueCb: (Function | null)[] = []

  private pageId: number

  constructor() {
    this.pageId = getCurrentWebViewId()
  }

  select(selector: string) {
    return new NodesRef(this, selector, true)
  }

  selectAll(selector: string) {
    return new NodesRef(this, selector, false)
  }

  selectViewport() {
    return new NodesRef(this, "", true)
  }

  exec(callback: Function) {
    const id = randomId()
    const message = [SyncFlags.SELECTOR, id, this.queue]
    sync(message, this.pageId)

    const result = (res: any) => {
      for (let i = 0; i < this.queueCb.length; i++) {
        const queueCallback = this.queueCb[i]
        isFunction(queueCallback) && queueCallback(res[i])
      }
      isFunction(callback) && callback(res)
    }
    selectorQueryCallbacks.set(id, result)
  }

  /** @internal */
  push(selector: string, single: boolean, fields: NodeFields, callback?: (object: any) => void) {
    this.queue.push({
      selector,
      single,
      fields
    })
    this.queueCb.push(callback || null)
  }
}

interface NodeRect {
  id: string
  dataset: Object
  left: number
  right: number
  top: number
  bottom: number
  width: number
  height: number
}

interface NodeScrollOffset {
  id: string
  dataset: Object
  scrollLeft: number
  scrollTop: number
}

interface NodeFields {
  [key: string]: boolean | undefined

  id?: boolean
  dataset?: boolean
  mask?: boolean
  rect?: boolean
  size?: boolean
  scrollOffset?: boolean
  properties?: boolean
  computedStyle?: boolean
  context?: boolean
  node?: boolean
}

interface ContextCallbackResult {
  context: any
}

class NodesRef {
  query: SelectorQuery
  selector: string
  single: boolean

  constructor(query: SelectorQuery, selector: string, single: boolean) {
    this.query = query
    this.selector = selector
    this.single = single
  }

  boundingClientRect(callback?: (object: NodeRect) => void) {
    this.query.push(
      this.selector,
      this.single,
      { id: true, dataset: true, rect: true, size: true },
      callback
    )
    return this.query
  }

  scrollOffset(callback?: (object: NodeScrollOffset) => void) {
    this.query.push(
      this.selector,
      this.single,
      { id: true, dataset: true, scrollOffset: true },
      callback
    )
    return this.query
  }

  fields(fields: NodeFields, callback?: (object: NodeScrollOffset) => void) {
    this.query.push(this.selector, this.single, fields, callback)
    return this.query
  }

  context(callback?: (res: ContextCallbackResult) => void) {
    this.query.push(
      this.selector,
      this.single,
      { id: true, dataset: true, context: true },
      (res: ContextCallbackResult) => {
        if (res.context) {
          res.context = createContextInstance(res.context)
        }
        callback && callback(res)
      }
    )
    return this.query
  }
}

export function createSelectorQuery() {
  return new SelectorQuery()
}

export interface ContextInfo {
  nodeId: number
  tagName: string
  contextId: number
  webViewId: number
}

function createContextInstance(context: ContextInfo) {
  const { tagName } = context

  switch (tagName) {
    case "EV-VIDEO":
      return createVideoContextInstance(context)
    default:
      break
  }
}
