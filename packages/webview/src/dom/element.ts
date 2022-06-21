import { createApp, reactive, createVNode, render, ComponentInternalInstance } from "vue"
import { toHandlerKey } from "@vue/shared"
import { BuiltInComponent, requireBuiltInComponent } from "../element"
import { restoreNode, NZVNode } from "./vnode"
import {
  touchEvents,
  dispatchEvent,
  createCustomEvent,
  addTouchEvent,
  tapEvents,
  addTapEvent
} from "./event"
import Loading from "../element/components/Loading.vue"

export type EL = Node | Element | HTMLElement | NZothElement | Text | Comment | SVGAElement

const vueApp = createApp({})
vueApp.config.warnHandler = msg => {
  console.warn(msg)
}
vueApp.config.errorHandler = err => {
  console.error(err)
}
vueApp.component("loading", Loading)

export function isNZothElement(el: any): el is NZothElement {
  return el && "__instance" in el
}

export interface NZothElement extends HTMLElement {
  __nodeId: number
  __instance: ComponentInternalInstance
  __slot: HTMLElement | null
}

export interface ElementWithTransition extends NZothElement {
  // _vtc = Vue Transition Classes.
  // Store the temporarily-added transition classes on the element
  // so that we can avoid overwriting them if the element's class is patched
  // during the transition.
  _vtc?: Set<string>
}

export const nodes = new Map<number, NZVNode>()

const svgNS = "http://www.w3.org/2000/svg"

export function createElement(data: any[]): EL | null {
  const nodeId = data[0] as number
  const has = nodes.get(nodeId)
  if (has) {
    return has.el
  }

  let el: NZothElement | HTMLElement | SVGElement | Text | Comment | null = null

  const node = restoreNode(data)
  if (node.tagName) {
    const component = requireBuiltInComponent(node.tagName)
    if (component) {
      el = createBuiltInComponent(node, component)
    } else {
      el = createNativeElement(node)
    }
  } else if (node.textContent || node.textContent === "") {
    el = document.createTextNode(node.textContent)
  } else if (node.data || node.data === "") {
    el = document.createComment(node.data)
  }

  if (el) {
    node.el = el
    node.el.__nodeId = nodeId
    nodes.set(node.nodeId, node)
  }
  return el
}

function createBuiltInComponent(node: NZVNode, component: BuiltInComponent) {
  node.props = reactive({})

  const { id, nodeId, props, className, style, attributes, listeners, textContent } = node

  if (id) {
    props.id = id
  }

  if (className) {
    props.class = className
  }

  if (attributes) {
    for (const [key, value] of Object.entries<string>(attributes)) {
      props[key] = value
    }
  }

  if (style) {
    props.style = {}
    for (const [name, value] of Object.entries<string>(style)) {
      props.style[name] = value
    }
  }

  let vnodeInstance: ComponentInternalInstance

  const wrapper = createVNode(() => {
    const vnode = createVNode(component.component, props)
    vnode.appContext = vueApp._context
    /** @ts-ignore */
    vnode.ce = (instance: ComponentInternalInstance) => {
      vnodeInstance = instance
    }
    return vnode
  })
  wrapper.appContext = vueApp._context

  const template = document.createElement("template")
  render(wrapper, template)

  const el = template.firstElementChild as NZothElement
  el.__instance = vnodeInstance!

  if (component.slot) {
    const slot = el.querySelector(component.slot) as HTMLElement
    slot && (el.__slot = slot)
  }

  if (textContent) {
    ;(el.__slot || el).textContent = textContent
  }

  if (listeners) {
    for (const [name, options] of Object.entries(listeners)) {
      if (touchEvents.includes(name)) {
        addTouchEvent(nodeId, el, name, options)
      } else if (tapEvents.includes(name)) {
        addTapEvent(nodeId, el, name, options)
      } else {
        const eventName = toHandlerKey(name)
        props[eventName] = (...args: any[]) => {
          const ev = {
            type: name,
            args: name.startsWith("update:") ? args : [createCustomEvent(el, name, args[0])]
          }
          dispatchEvent(nodeId, ev)
        }
      }
    }
  }

  node.vnode = wrapper

  return el
}

function createNativeElement(node: NZVNode) {
  const { isSVG, tagName, className, id, nodeId, attributes, listeners, textContent, style } = node

  let el: HTMLElement | SVGElement

  if (isSVG) {
    el = document.createElementNS(svgNS, tagName)
    if (className) {
      el.setAttribute("class", className)
    }
  } else {
    el = document.createElement(tagName)
    if (className) {
      el.className = className
    }
  }

  if (id) {
    el.id = id
  }

  if (attributes) {
    for (const [key, value] of Object.entries<string>(attributes)) {
      el.setAttribute(key, value)
    }
  }

  if (listeners) {
    for (const [name, options] of Object.entries(listeners)) {
      if (touchEvents.includes(name)) {
        addTouchEvent(nodeId, el, name, options)
      } else if (tapEvents.includes(name)) {
        addTapEvent(nodeId, el, name, options)
      } else {
        el.addEventListener(
          name,
          () => {
            dispatchEvent(nodeId, name)
          },
          options.options
        )
      }
    }
  }

  if (textContent) {
    el.textContent = textContent
  }

  if (style) {
    for (const [name, value] of Object.entries<string>(style)) {
      el.style[name as any] = value
    }
  }

  return el
}
