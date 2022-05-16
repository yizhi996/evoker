import { VNode } from "vue"
import { unmountComponent } from "../runtime-jscore/patchUnmount"
import { NZothElement } from "./element"
import { NZothHTMLElement } from "./html"
import { SyncFlags } from "@nzoth/shared"
import { sync } from "@nzoth/bridge"
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

  constructor(pageId: number, route: string, tabIndex: number) {
    this.pageId = pageId
    this.route = route
    this.tabIndex = tabIndex
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

  onInsertBefore(parent: NZothNode, child: NZothNode, anchor?: NZothNode | null) {
    let message = [SyncFlags.INSERT, minifyNode(child), minifyNode(parent)]
    if (anchor) {
      message.push(minifyNode(anchor))
    }
    sync(message, this.pageId)
  }

  onRemove(parent: NZothNode, child: NZothNode) {
    child.isMounted = false
    this.nodes.delete(child.nodeId)
    const message = [SyncFlags.REMOVE, parent.nodeId, child.nodeId]
    sync(message, this.pageId)
  }

  onPatchStyle(el: NZothElement) {
    if (!el.isMounted) {
      return
    }
    const message = [
      SyncFlags.UPDATE_PROP,
      el.nodeId,
      "style",
      (el as NZothHTMLElement).style.styleObject
    ]
    sync(message, this.pageId)
  }

  onShow(el: NZothElement) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.DISPLAY, el.nodeId, (el as NZothHTMLElement).style.display]
    sync(message, this.pageId)
  }

  onPatchProp(el: NZothElement, name: string, value?: any) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.UPDATE_PROP, el.nodeId, name, value]
    sync(message, this.pageId)
  }

  onSetElementText(el: NZothNode, textContent: string) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.SET_TEXT, el.nodeId, textContent]
    sync(message, this.pageId)
  }

  onSetModelValue(nodeId: number, value: any) {
    const message = [SyncFlags.SET_MODEL_VALUE, nodeId, value]
    sync(message, this.pageId)
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
    const message = [SyncFlags.ADD_EVENT, el.nodeId, { type, options, modifiers }]
    sync(message, this.pageId)
  }
}
