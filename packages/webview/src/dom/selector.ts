import { isEvokerElement } from "./element"
import { SyncFlags } from "@evoker/shared"
import { sync } from "@evoker/bridge"

interface SelectorQueueItem {
  selector: string
  single: boolean
  fields: Record<string, boolean>
}

export function selector(data: any[]) {
  const [_, id, queue] = data as [SyncFlags, number, SelectorQueueItem[]]

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

    if (fields.context) {
      if (isEvokerElement(el)) {
        if (["EK-VIDEO"].includes(el.tagName)) {
          const instance = el.__instance
          const contextId = instance.exposed!.getContextId()
          res.context = {
            nodeId: el.__nodeId,
            tagName: el.tagName,
            contextId,
            webViewId: window.webViewId
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

  const message = [SyncFlags.SELECTOR, id, resList]

  sync(message, window.webViewId)
}
