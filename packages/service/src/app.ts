import { Component, AppContext, reactive, createVNode, App } from "vue"
import { renderer } from "./runtime-jscore/renderer"
import { InnerJSBridge } from "./bridge/bridge"
import { EvokerPage } from "./dom/page"
import { EvokerHTMLElement } from "./dom/html"
import { EvokerEvent } from "./dom/eventTarget"
import { getPageComponentFormRoute, decodeURL } from "./router"
import { onSync } from "@evoker/bridge"
import { SyncFlags } from "@evoker/shared"
import { invokeSelectorQuery } from "./bridge/api/html/selector"
import { intersectionObserverEntry } from "./bridge/api/html/intersection"
import { invokeAppOnError } from "./lifecycle/global"
import { LifecycleHooks } from "./lifecycle/hooks"

export const enum AppState {
  FORE_GROUND = 0,
  BACK_GROUND
}

export const innerAppData = {
  appState: AppState.FORE_GROUND,
  globalData: {},
  pages: new Map<number, EvokerPage>(),
  pageStack: new Map<number, EvokerPage[]>(),
  currentTabIndex: 0,
  query: {},
  routerLock: false,
  eventFromUserClick: false
}

let vueContext: AppContext

export function createApp(
  rootComponent: Component,
  rootProps?: Record<string, unknown> | null | undefined
): App<Element> {
  const app = renderer.createApp(rootComponent, rootProps)
  const { mount } = app
  app.mount = () => {
    const page = new EvokerPage(-999, "hook", 0)
    const root = new EvokerHTMLElement("div", page)
    root.id = "app"
    const { errorHandler } = app.config
    app.config.errorHandler = (err, instance, info) => {
      invokeAppOnError(err as string)
      errorHandler && errorHandler(err, instance, info)
    }
    return mount(root, false, false)
  }
  vueContext = app._context
  /** @ts-ignore */
  return app
}

export function getCurrentPages() {
  return innerAppData.pageStack.get(innerAppData.currentTabIndex) || []
}

export function getCurrentWebViewId() {
  return getCurrentPage().pageId
}

export function getCurrentPage() {
  const pages = getCurrentPages()
  return pages[pages.length - 1]
}

export function getApp() {
  return { globalData: innerAppData.globalData }
}

interface MountOptions {
  pageId: number
  path: string
  tabIndex: number
  fromTabItemTap: boolean
  tabText: string
}

export function mountPage(options: MountOptions) {
  const { pageId, path, tabIndex, fromTabItemTap, tabText } = options
  const { path: route, query } = decodeURL(path)

  const component = getPageComponentFormRoute(route)
  if (!component) {
    console.error(`${route} 未定义，请在 app.json 的 pages 中定义`)
    return
  }

  innerAppData.currentTabIndex = tabIndex

  const page = new EvokerPage(pageId, route, tabIndex)

  const stack = innerAppData.pageStack.get(tabIndex)
  if (stack) {
    stack.push(page)
  } else {
    innerAppData.pageStack.set(tabIndex, [page])
  }
  innerAppData.pages.set(pageId, page)

  const vnode = createVNode(component, {
    __pageId: pageId,
    __route: route,
    __query: query
  })
  ;(vnode as any).__pageId = pageId
  ;(vnode as any).__route = route
  vnode.appContext = vueContext

  page.vnode = vnode

  const root = new EvokerHTMLElement("div", page)
  root.id = "app"
  renderer.render(vnode, root)

  if (fromTabItemTap) {
    InnerJSBridge.subscribeHandler(LifecycleHooks.PAGE_ON_TAB_ITEM_TAP, {
      pageId,
      index: tabIndex,
      pagePath: route,
      text: tabText,
      fromTap: fromTabItemTap
    })
  }
}

export function unmountPage(pageId: number) {
  const page = innerAppData.pages.get(pageId)
  if (page) {
    page.onUnmounted()
    innerAppData.pages.delete(pageId)

    const stack = innerAppData.pageStack.get(page.tabIndex)
    if (stack) {
      const i = stack.findIndex(p => p.pageId === pageId)
      i > -1 && stack.splice(i, 1)
    }
  }
}

onSync(messages => {
  messages.forEach(message => {
    const flag = message[0]
    if (flag === SyncFlags.DISPATCH_EVENT) {
      dispatchEvent(message)
    } else if (flag === SyncFlags.SELECTOR) {
      invokeSelectorQuery(message)
    } else if (flag === SyncFlags.INTERSECTION_OBSERVER_ENTRY) {
      intersectionObserverEntry(message)
    }
  })
})

function dispatchEvent(data: any[]) {
  const [_, pageId, nodeId, event] = data
  const page = innerAppData.pages.get(pageId)
  if (page) {
    const node = page.nodes.get(nodeId)
    if (node) {
      const customEvent = new EvokerEvent(event.type)
      customEvent.target = node
      customEvent.args = event.args
      innerAppData.eventFromUserClick = event.type === "click"
      node.dispatchEvent(customEvent)
      innerAppData.eventFromUserClick = false
    }
  }
}
