import { InnerJSBridge } from "../bridge/bridge"
import { isFunction } from "@nzoth/shared"
import { unmountPage } from "../app"

export const enum LifecycleHooks {
  APP_ON_LAUNCH = "APP_ON_LAUNCH",
  APP_ON_SHOW = "APP_ON_SHOW",
  APP_ON_HIDE = "APP_ON_HIDE",

  PAGE_ON_LOAD = "PAGE_ON_LOAD",
  PAGE_ON_SHOW = "PAGE_ON_SHOW",
  PAGE_ON_READY = "PAGE_ON_READY",
  PAGE_ON_UNLOAD = "PAGE_ON_UNLOAD",
  PAGE_ON_HIDE = "PAGE_ON_HIDE",
  PAGE_ON_PULL_DOWN_REFRESH = "PAGE_ON_PULL_DOWN_REFRESH",
  PAGE_ON_REACH_BOTTOM = "PAGE_ON_REACH_BOTTOM",
  PAGE_ON_SCROLL = "PAGE_ON_SCROLL",
  PAGE_ON_RESIZE = "PAGE_ON_RESIZE",
  PAGE_ON_TAB_ITEM_TAP = "PAGE_ON_TAB_ITEM_TAP",
  PAGE_ON_SAVE_EXIT_STATE = "PAGE_ON_SAVE_EXIT_STATE"
}

const appEvents: Record<string, Function[]> = {}
const pageEvents: Record<string, Map<number, Function>> = {}

function injectHook(
  lifecycle: LifecycleHooks,
  hook: Function,
  pageId?: number
) {
  if (pageId === undefined) {
    const hooks = appEvents[lifecycle] || (appEvents[lifecycle] = [])
    hooks.push(hook)
    return hook
  }
  const hooks = pageEvents[lifecycle] || (pageEvents[lifecycle] = new Map())
  hooks.set(pageId, hook)
  if (lifecycle === LifecycleHooks.PAGE_ON_SCROLL) {
    InnerJSBridge.invoke("pageLifeRequired", {
      pageId,
      onPageScroll: true
    })
  }
  return hook
}

export function createHook<T extends Function = () => void>(
  lifecycle: LifecycleHooks,
  hook: T,
  pageId?: number
) {
  return injectHook(lifecycle, hook, pageId)
}

function invokeAppHook(lifecycle: LifecycleHooks, data?: any) {
  const hooks = appEvents[lifecycle]
  if (hooks) {
    hooks.forEach(hook => isFunction(hook) && hook(data))
  }
}

function invokePageHook(lifecycle: LifecycleHooks, pageId: number, data?: any) {
  const events = pageEvents[lifecycle]
  if (events) {
    const hook = events.get(pageId)
    if (hook && isFunction(hook)) {
      hook(data)
    }
  }
}

InnerJSBridge.subscribe(LifecycleHooks.APP_ON_LAUNCH, message => {
  invokeAppHook(LifecycleHooks.APP_ON_LAUNCH, message)
})

InnerJSBridge.subscribe(LifecycleHooks.APP_ON_SHOW, message => {
  invokeAppHook(LifecycleHooks.APP_ON_SHOW, message)
})

InnerJSBridge.subscribe(LifecycleHooks.APP_ON_HIDE, () => {
  invokeAppHook(LifecycleHooks.APP_ON_HIDE)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_LOAD, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_LOAD, message.pageId, message.query)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_SHOW, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_SHOW, message.pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_READY, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_READY, message.pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_HIDE, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_HIDE, message.pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_UNLOAD, message => {
  const { pageId } = message
  unmountPage(pageId)
  invokePageHook(LifecycleHooks.PAGE_ON_UNLOAD, pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_PULL_DOWN_REFRESH, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_PULL_DOWN_REFRESH, message.pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_REACH_BOTTOM, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_REACH_BOTTOM, message.pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_SCROLL, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_SCROLL, message.pageId, {
    scrollTop: message.scrollTop
  })
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_RESIZE, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_RESIZE, message.pageId)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_TAB_ITEM_TAP, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_RESIZE, message.pageId, message)
})

InnerJSBridge.subscribe(LifecycleHooks.PAGE_ON_SAVE_EXIT_STATE, message => {
  invokePageHook(
    LifecycleHooks.PAGE_ON_SAVE_EXIT_STATE,
    message.pageId,
    message
  )
})
