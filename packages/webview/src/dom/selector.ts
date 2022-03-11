import { NZJSBridge } from "../bridge"
import { isNZothElement, nodes } from "./element"

const SelectorQueryKey = "selectorQuery"

NZJSBridge.subscribe(SelectorQueryKey, message => {
  const queue = message.queue as {
    selector: string
    single: boolean
    fields: Record<string, boolean>
  }[]

  let resList: Record<string, any>[] = []

  function getFields(el: Element, fields: Record<string, boolean>) {
    const res: Record<string, any> = {}
    if (fields.id) {
      res.id = el.id
    }
    if (fields.rect || fields.size) {
      const rect = el.getBoundingClientRect()
      if (fields.rect) {
        res.left = rect.left
        res.right = rect.right
        res.top = rect.top
        res.bottom = rect.bottom
      }
      if (fields.size) {
        res.width = rect.width
        res.height = rect.height
      }
    }
    if (fields.scrollOffset) {
      res.scrollLeft = el.scrollLeft
      res.scrollTop = el.scrollTop
      res.scrollWidth = el.scrollWidth
      res.scrollHeight = el.scrollHeight
    }
    if (fields.node) {
      if (isNZothElement(el)) {
        const llnode = nodes.get(el.__nodeId)
        if (llnode && llnode.vnode) {
          const { vnode } = llnode
          res.node = { nodeIs: el.tagName, nodeId: el.__nodeId }

          if (
            el.tagName === "nz-canvas" &&
            vnode.component &&
            vnode.component.exposed
          ) {
            const { type, canvasId } = vnode.component.exposed
            res.node.canvasType = type
            res.node.canvasId = canvasId
          }
        }
      }
    }
    return res
  }

  queue.forEach(item => {
    const { selector, single, fields } = item
    if (single) {
      const el = document.querySelector(selector) as HTMLElement
      if (el) {
        const res = getFields(el, fields)
        resList.push(res)
      }
    } else {
      const els = document.querySelectorAll(selector)
      const arr: Record<string, any>[] = []
      els.forEach(el => {
        const res = getFields(el, fields)
        arr.push(res)
      })
      resList.push(arr)
    }
  })

  NZJSBridge.publish(
    SelectorQueryKey,
    { id: message.id, list: resList },
    window.webViewId
  )
})
