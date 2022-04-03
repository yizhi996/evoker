import { getCurrentInstance } from "vue"
import { InnerJSBridge } from "../bridge/bridge"
import { LifecycleHooks, createHook } from "./hooks"

interface PageScrollObject {
  scrollTop: number
}

export default function usePage() {
  const instance = getCurrentInstance()
  if (!instance) {
    console.warn(
      "[NZoth] usePage 必须在 setup 或 生命周期中使用，查看 https://v3.vuejs.org/api/composition-api.html#getcurrentinstance"
    )
  }

  const pageId = (instance!.vnode as any).__pageId as number

  return {
    onLoad: (hook: (query: Record<string, any>) => void) => {
      return createHook(LifecycleHooks.PAGE_ON_LOAD, hook, pageId)
    },
    onShow: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_SHOW, hook, pageId)
    },
    onReady: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_READY, hook, pageId)
    },
    onHide: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_HIDE, hook, pageId)
    },
    onUnload: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_UNLOAD, hook, pageId)
    },
    onPullDownRefresh: (hook: () => void) => {
      InnerJSBridge.invoke("addPullDownRefresh", { pageId })
      return createHook(LifecycleHooks.PAGE_ON_PULL_DOWN_REFRESH, hook, pageId)
    },
    onReachBottom: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_REACH_BOTTOM, hook, pageId)
    },
    onPageScroll: (hook: (object: PageScrollObject) => void) => {
      return createHook(LifecycleHooks.PAGE_ON_SCROLL, hook, pageId)
    },
    onResize: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_RESIZE, hook, pageId)
    },
    onTabItemTap: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_TAB_ITEM_TAP, hook, pageId)
    },
    onSaveExitState: (hook: () => void) => {
      return createHook(LifecycleHooks.PAGE_ON_SAVE_EXIT_STATE, hook, pageId)
    }
  }
}
