import { VNode } from "vue"
import { unmountComponent } from "../runtime-jscore/patchUnmount"
import { EvokerElement } from "./element"
import { EvokerHTMLElement } from "./html"
import { SyncFlags } from "@evoker/shared"
import { sync } from "@evoker/bridge"
import { EvokerNode } from "./node"
import { minifyNode } from "./utils"

export class EvokerPage {
  pageId: number

  route: string

  tabIndex: number

  /**  @internal */
  nodes = new Map<number, EvokerNode>()

  /**  @internal */
  vnode?: VNode

  private childId = 0

  constructor(pageId: number, route: string, tabIndex: number) {
    this.pageId = pageId
    this.route = route
    this.tabIndex = tabIndex
  }

  appendChildNode(node: EvokerNode) {
    node.nodeId = ++this.childId
    this.nodes.set(node.nodeId, node)
  }

  onUnmounted() {
    this.vnode && unmountComponent(this.vnode.component!)
    this.vnode = undefined
    this.nodes.clear()
  }

  onInsertBefore(parent: EvokerNode, child: EvokerNode, anchor?: EvokerNode | null) {
    const message = [
      SyncFlags.INSERT,
      child.isMounted ? [child.nodeId] : minifyNode(child),
      parent.isMounted ? [parent.nodeId] : minifyNode(parent)
    ]
    if (anchor) {
      message.push(anchor.isMounted ? [anchor.nodeId] : minifyNode(anchor))
    }
    sync(message, this.pageId)
  }

  onRemove(parent: EvokerNode, child: EvokerNode) {
    this.nodes.delete(child.nodeId)
    const message = [SyncFlags.REMOVE, parent.nodeId, child.nodeId]
    sync(message, this.pageId)
  }

  onPatchStyle(el: EvokerElement) {
    if (!el.isMounted) {
      return
    }
    const message = [
      SyncFlags.UPDATE_PROP,
      el.nodeId,
      "style",
      (el as EvokerHTMLElement).style.styleObject
    ]
    sync(message, this.pageId)
  }

  onShow(el: EvokerElement) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.DISPLAY, el.nodeId, (el as EvokerHTMLElement).style.display]
    sync(message, this.pageId)
  }

  onPatchProp(el: EvokerElement, name: string, value?: any) {
    if (!el.isMounted) {
      return
    }
    const message = [SyncFlags.UPDATE_PROP, el.nodeId, name, value]
    sync(message, this.pageId)
  }

  onSetElementText(el: EvokerNode, textContent: string) {
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
    el: EvokerNode,
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
