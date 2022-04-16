import { getCurrentPages } from "../../../app"
import { NZothPage } from "../../../dom/page"
import { createCanvasNode } from "./node"
import { isFunction, SyncFlags } from "@nzoth/shared"
import { randomId } from "../../../utils"
import { sync } from "@nzoth/bridge"

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

  private page: NZothPage

  constructor() {
    const pages = getCurrentPages()
    this.page = pages[pages.length - 1]
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
    sync(message, this.page.pageId)

    const result = (res: any) => {
      for (let i = 0; i < this.queueCb.length; i++) {
        const queueCallback = this.queueCb[i]
        const node = res[i].node
        if (node) {
          if (node.nodeIs === "nz-canvas") {
            createCanvasNode(node.nodeId, node.canvasType, node.canvasId)
          }
        }
        isFunction(queueCallback) && queueCallback(res[i])
      }
      isFunction(callback) && callback(res)
    }
    selectorQueryCallbacks.set(id, result)
  }

  /** @internal */
  push(
    selector: string,
    single: boolean,
    fields: NodeFields,
    callback?: (object: any) => void
  ) {
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
}

export function createSelectorQuery() {
  return new SelectorQuery()
}
