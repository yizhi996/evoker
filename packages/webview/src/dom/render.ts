import {
  touchEvents,
  dispatchEvent,
  createCustomEvent,
  tapEvents,
  addTouchEvent,
  addTapEvent
} from "./event"
import { nodes, createElement, ElementWithTransition } from "./element"
import { restoreNode } from "./vnode"
import { isEvokerElement, EL } from "./element"
import { toHandlerKey } from "@vue/shared"
import { SyncFlags } from "@evoker/shared"

export function insertBefore(data: any[]) {
  const [_, childData, parentData, anchorData] = data
  let parentEl: EL | null = null
  if (parentData && parentData[3] === "app") {
    const parent = restoreNode(parentData)
    const el = document.getElementById(parent.id)
    parentEl = el
    parent.el = el
    nodes.set(parent.nodeId, parent)
  } else {
    parentEl = createElement(parentData)
  }
  const childEL = createElement(childData)
  let anchorEl: EL | null = null
  if (anchorData) {
    anchorEl = createElement(anchorData)
  }
  if (parentEl && childEL) {
    const target = (isEvokerElement(parentEl) && parentEl.__slot) || parentEl
    target.insertBefore(childEL, anchorEl)
  }
}

export function removeChild(data: any[]) {
  const [_, parentNodeId, childNodeId] = data as [SyncFlags, number, number]
  const parent = nodes.get(parentNodeId)
  if (parent && parent.el) {
    const child = nodes.get(childNodeId)
    if (child && child.el) {
      nodes.delete(childNodeId)

      // 如果在内置组件的 slot 内，可能 parent 和 parentNodeId 获取到的不一致
      // 内置组件由多个 wrapper 嵌套
      const el = child.el as Node
      el.parentNode && el.parentNode.removeChild(el)

      removeChildNodes(child.el as Node)
    }
  }
}

type LLChildNode = ChildNode & { __nodeId: number }

function removeChildNodes(node: Node) {
  const cn = node.childNodes as NodeListOf<LLChildNode>
  for (let i = 0; i < cn.length; i++) {
    const node = cn[i]
    if (node.__nodeId) {
      removeChildNodes(node)
      nodes.delete(node.__nodeId)
    } else {
      break
    }
  }
}

export function setText(data: any[]) {
  const [_, nodeId, textContent] = data
  const node = nodes.get(nodeId)
  if (node && node.el) {
    const target = (isEvokerElement(node.el) && node.el.__slot) || node.el
    target.textContent = textContent
  }
}

export function setDisplay(data: any[]) {
  const [_, nodeId, value] = data as [SyncFlags, number, string]
  const node = nodes.get(nodeId)
  if (node && node.el) {
    const { el, props } = node
    if (isEvokerElement(el)) {
      const style = props!.style || (props!.style = {})
      style.display = value
    } else if (value) {
      el.style.display = value
    } else {
      el.style.display = null
    }
  }
}

export function addEventListener(data: any[]) {
  const [_, nodeId, event] = data as [
    SyncFlags,
    number,
    { type: string; options: EventListenerOptions; modifiers: string[] }
  ]
  const { type, options, modifiers } = event
  const node = nodes.get(nodeId)
  if (node && node.el) {
    const { el, props } = node
    if (touchEvents.includes(type)) {
      addTouchEvent(nodeId, el, type, { options, modifiers })
    } else if (tapEvents.includes(type)) {
      addTapEvent(nodeId, el, type, { options, modifiers })
    } else {
      if (isEvokerElement(el)) {
        const eventName = toHandlerKey(type)
        props![eventName] = (...args: any[]) => {
          const ev = {
            type: type,
            args: type.startsWith("update:") ? args : [createCustomEvent(el, type, args[0])]
          }
          dispatchEvent(nodeId, ev)
        }
      } else {
        el.addEventListener(
          type,
          () => {
            dispatchEvent(nodeId, type)
          },
          options
        )
      }
    }
  }
}

export function updateProp(data: any[]) {
  const [_, nodeId, name, value] = data
  const node = nodes.get(nodeId)
  if (node && node.el) {
    const { el, props } = node
    if (isEvokerElement(el)) {
      props![name] = value
    } else if (name === "id") {
      el.id = value
    } else if (name === "class") {
      if (el instanceof SVGAElement) {
        value == null ? el.removeAttribute("class") : el.setAttribute("class", value)
      } else {
        let className = value
        const transitionClasses = (el as ElementWithTransition)._vtc
        if (transitionClasses) {
          className = (value ? [value, ...transitionClasses] : [...transitionClasses]).join(" ")
        }
        el.className = className
      }
    } else if (name === "style") {
      const style = value as Record<string, string>
      if (value) {
        if (isEvokerElement(el)) {
          if (props!.style || (props!.style = {})) {
            for (const [property, value] of Object.entries<string>(style)) {
              props!.style[property] = value
            }
          }
        } else {
          for (const [property, value] of Object.entries<string>(style)) {
            el.style[property] = value
          }
        }
      } else {
        isEvokerElement(el) ? (props!.style = null) : (el.style = null)
      }
    } else {
      if (value == null) {
        el.removeAttribute(name)
      } else {
        if (node.el instanceof SVGAElement) {
          el.setAttributeNS(null, name, value)
        } else {
          el.setAttribute(name, value)
        }
      }
    }
  }
}

export function setModelValue(data: any[]) {
  const [_, nodeId, value] = data
  const node = nodes.get(nodeId)
  if (node) {
    node.props!.modelValue = value
  }
}
