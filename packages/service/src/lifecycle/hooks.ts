import { InnerJSBridge } from "../bridge/bridge"
import { dispatchEvent, extend, isFunction } from "@nzoth/shared"
import { unmountPage } from "../app"
import { decodeURL } from "../router"

export const enum LifecycleHooks {
  APP_ON_LAUNCH = "APP_ON_LAUNCH",
  APP_ON_SHOW = "APP_ON_SHOW",
  APP_ON_HIDE = "APP_ON_HIDE",
  APP_ON_ERROR = "APP_ON_ERROR",
  APP_THEME_CHANGE = "APP_THEME_CHANGE",

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

const pageEvents: Record<number, Map<LifecycleHooks, Function>> = {}

const pageEffectHooks: Record<number, Record<string, boolean>> = {}

function injectHook(lifecycle: LifecycleHooks, hook: Function, pageId?: number) {
  if (pageId === undefined) {
    const hooks = appEvents[lifecycle] || (appEvents[lifecycle] = [])
    hooks.push(hook)
    return hook
  }

  const hooks = pageEvents[pageId] || (pageEvents[pageId] = new Map())
  hooks.set(lifecycle, hook)

  const effects = pageEffectHooks[pageId] || (pageEffectHooks[pageId] = {})
  if (lifecycle === LifecycleHooks.PAGE_ON_SCROLL) {
    effects["onPageScroll"] = true
  } else if (lifecycle === LifecycleHooks.PAGE_ON_PULL_DOWN_REFRESH) {
    effects["onPullDownRefresh"] = true
  }

  if (Object.keys(effects).length) {
    InnerJSBridge.invoke("pageEffect", {
      pageId,
      hooks: effects
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
  const events = pageEvents[pageId]
  if (events) {
    const hook = events.get(lifecycle)
    hook && isFunction(hook) && hook(data)
  }
}

InnerJSBridge.subscribe<{ path: string }>(LifecycleHooks.APP_ON_LAUNCH, message => {
  const options = extend(message, decodeURL(message.path))
  invokeAppHook(LifecycleHooks.APP_ON_LAUNCH, options)
})

InnerJSBridge.subscribe<{ path: string }>(LifecycleHooks.APP_ON_SHOW, message => {
  const options = extend(message, decodeURL(message.path))
  invokeAppHook(LifecycleHooks.APP_ON_SHOW, options)
  dispatchEvent(LifecycleHooks.APP_ON_SHOW, options)
})

InnerJSBridge.subscribe(LifecycleHooks.APP_ON_HIDE, () => {
  invokeAppHook(LifecycleHooks.APP_ON_HIDE)
  dispatchEvent(LifecycleHooks.APP_ON_HIDE)
})

InnerJSBridge.subscribe(LifecycleHooks.APP_ON_ERROR, message => {
  invokeAppHook(LifecycleHooks.APP_ON_ERROR, message)
  dispatchEvent(LifecycleHooks.APP_ON_ERROR, message)
})

InnerJSBridge.subscribe(LifecycleHooks.APP_THEME_CHANGE, message => {
  invokeAppHook(LifecycleHooks.APP_THEME_CHANGE, message)
  dispatchEvent(LifecycleHooks.APP_THEME_CHANGE, message)
})

InnerJSBridge.subscribe<{ pageId: number; query: Record<string, any> }>(
  LifecycleHooks.PAGE_ON_LOAD,
  message => {
    invokePageHook(LifecycleHooks.PAGE_ON_LOAD, message.pageId, message.query)
  }
)

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_SHOW, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_SHOW, message.pageId)
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_READY, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_READY, message.pageId)
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_HIDE, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_HIDE, message.pageId)
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_UNLOAD, message => {
  const { pageId } = message
  unmountPage(pageId)
  invokePageHook(LifecycleHooks.PAGE_ON_UNLOAD, pageId)
  delete pageEvents[pageId]
  delete pageEffectHooks[pageId]
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_PULL_DOWN_REFRESH, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_PULL_DOWN_REFRESH, message.pageId)
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_REACH_BOTTOM, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_REACH_BOTTOM, message.pageId)
})

InnerJSBridge.subscribe<{ pageId: number; scrollTop: number }>(
  LifecycleHooks.PAGE_ON_SCROLL,
  message => {
    invokePageHook(LifecycleHooks.PAGE_ON_SCROLL, message.pageId, {
      scrollTop: message.scrollTop
    })
  }
)

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_RESIZE, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_RESIZE, message.pageId)
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_TAB_ITEM_TAP, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_RESIZE, message.pageId, message)
})

InnerJSBridge.subscribe<{ pageId: number }>(LifecycleHooks.PAGE_ON_SAVE_EXIT_STATE, message => {
  invokePageHook(LifecycleHooks.PAGE_ON_SAVE_EXIT_STATE, message.pageId, message)
})
