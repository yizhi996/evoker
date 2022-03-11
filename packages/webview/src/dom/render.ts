import { addClickEvent, dispatchEvent } from "./event"
import { nodes, createElement, ElementWithTransition } from "./element"
import { restoreNode } from "./vnode"
import { isNZothElement, EL } from "./element"
import { toHandlerKey } from "@vue/shared"

export function insertBefore(data: any[]) {
  const [_, childData, parentData, anchorData] = data
  let parentEl: EL | null
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
    const target = (isNZothElement(parentEl) && parentEl.__slot) || parentEl
    target.insertBefore(childEL, anchorEl)
  }
}

export function removeChild(data: any[]) {
  const [_, parentNodeId, childNodeId] = data
  const parent = nodes.get(parentNodeId)
  if (parent && parent.el) {
    const child = nodes.get(childNodeId)
    if (child && child.el) {
      nodes.delete(childNodeId)

      parent.el.removeChild(child.el)

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
    const target = (isNZothElement(node.el) && node.el.__slot) || node.el
    target.textContent = textContent
  }
}

export function setClass(data: any[]) {
  const [_, nodeId, className] = data
  const node = nodes.get(nodeId)
  if (node && node.el) {
    let value = className
    const transitionClasses = (node.el as ElementWithTransition)._vtc
    if (transitionClasses) {
      value = (
        value ? [value, ...transitionClasses] : [...transitionClasses]
      ).join(" ")
    }
    node.el.className = value
  }
}

export function setStyle(data: any[]) {
  const [_, nodeId, style] = data
  const node = nodes.get(nodeId)
  if (node && node.el) {
    if (style) {
      if (isNZothElement(node.el)) {
        const props = node.props!
        if (props.style || (props.style = {})) {
          for (const [name, value] of Object.entries<string>(style)) {
            props.style[name] = value
          }
        }
      } else {
        for (const [name, value] of Object.entries<string>(style)) {
          node.el.style[name] = value
        }
      }
    } else {
      node.el.style = null
    }
  }
}

export function setDisplay(data: any[]) {
  const [_, nodeId, show] = data
  const node = nodes.get(nodeId)
  if (node && node.el) {
    if (isNZothElement(node.el)) {
      const props = node.props!
      if (props.style || (props.style = {})) {
        props.style.display = show
      }
    } else if (show) {
      node.el.style.display = show
    } else {
      node.el.style.display = null
    }
  }
}

export function addEventListener(data: any[]) {
  const [_, nodeId, event] = data
  const { type, listener, options, modifiers } = event
  const node = nodes.get(nodeId)
  if (node && node.el) {
    if (type === "click") {
      const elOptions = {
        options,
        modifiers
      }
      addClickEvent(nodeId, node.el, elOptions)
    } else {
      if (isNZothElement(node.el)) {
        const eventName = toHandlerKey(type)
        node.props![eventName] = (...args: any[]) => {
          const ev = {
            type: type,
            args: args
          }
          dispatchEvent(nodeId, ev)
        }
      } else {
        node.el.addEventListener(
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
    if (isNZothElement(node.el)) {
      const props = node.props!
      props[name] = value
    } else if (value === undefined || value === null) {
      if (node.el instanceof SVGAElement) {
        node.el.removeAttributeNS(null, name)
      } else {
        node.el.removeAttribute(name)
      }
    } else {
      if (node.el instanceof SVGAElement) {
        node.el.setAttributeNS(null, name, value)
      } else {
        node.el.setAttribute(name, value)
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
