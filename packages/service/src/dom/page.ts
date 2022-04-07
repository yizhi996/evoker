import { queuePostFlushCb, VNode } from "vue"
import { unmountComponent } from "../runtime-jscore/patchUnmount"
import { NZothElement } from "./element"
import { NZothHTMLElement } from "./html"
import { SyncFlags } from "@nzoth/shared"
import { pipeline } from "@nzoth/bridge"
import { NZothNode } from "./node"
import { minifyNode } from "./utils"

export class NZothPage {
  pageId: number

  route: string

  tabIndex: number

  /**  @internal */
  nodes = new Map<number, NZothNode>()

  /**  @internal */
  vnode?: VNode

  private childId = 0

  private messageQueue: any[] = []

  private sync: () => void

  constructor(pageId: number, route: string, tabIndex: number) {
    this.pageId = pageId
    this.route = route
    this.tabIndex = tabIndex
    this.sync = this._sync.bind(this)
  }

  appendChildNode(node: NZothNode) {
    node.nodeId = ++this.childId
    this.nodes.set(node.nodeId, node)
  }

  onUnmounted() {
    this.vnode && unmountComponent(this.vnode.component!)
    this.vnode = undefined
    this.nodes.clear()
  }

  private enqueue(message: any) {
    this.messageQueue.push(message)
    queuePostFlushCb(this.sync)
  }

  private _sync() {
    if (this.messageQueue.length === 0) {
      return
    }
    pipeline.sync(this.messageQueue, this.pageId)
    this.messageQueue = []
  }

  onInsertBefore(
    parent: NZothNode,
    child: NZothNode,
    anchor?: NZothNode | null
  ) {
    let message = [SyncFlags.INSERT, minifyNode(child), minifyNode(parent)]
    if (anchor) {
      message.push(minifyNode(anchor))
    }
    this.enqueue(message)
  }

  onRemove(parent: NZothNode, child: NZothNode) {
    child.isMounted = false
    this.nodes.delete(child.nodeId)
    const message = [SyncFlags.REMOVE, parent.nodeId, child.nodeId]
    this.enqueue(message)
  }

  onPatchClass(el: NZothElement) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.SET_CLASS, el.nodeId, el.className]
    this.enqueue(message)
  }

  onPatchStyle(el: NZothElement) {
    if (!el.isMounted) {
      return
    }
    const message = [
      SyncFlags.SET_STYLE,
      el.nodeId,
      (el as NZothHTMLElement).style.styleObject
    ]
    this.enqueue(message)
  }

  onShow(el: NZothElement) {
    if (!el.isMounted) {
      return
    }
    const message = [
      SyncFlags.DISPLAY,
      el.nodeId,
      (el as NZothHTMLElement).style.display
    ]
    this.enqueue(message)
  }

  onPatchProp(el: NZothElement, name: string, value?: any) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.UPDATE_PROP, el.nodeId, name, value]
    this.enqueue(message)
  }

  onSetElementText(el: NZothNode, textContent: string) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.SET_TEXT, el.nodeId, textContent]
    this.enqueue(message)
  }

  onSetModelValue(nodeId: number, value: any) {
    const message = [SyncFlags.SET_MODEL_VALUE, nodeId, value]
    this.enqueue(message)
  }

  onAddEventListener(
    el: NZothNode,
    type: string,
    options?: EventListenerOptions,
    modifiers?: string[]
  ) {
    if (!el.isMounted) {
      return
    }
    const message = [
      SyncFlags.ADD_EVENT,
      el.nodeId,
      { type, options, modifiers }
    ]
    this.enqueue(message)
  }
}
