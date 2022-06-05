import { InnerJSBridge } from "../bridge"
import {
  AsyncReturn,
  SuccessResult,
  GeneralCallbackResult,
  invokeCallback,
  invokeFailure,
  invokeSuccess,
  wrapperAsyncAPI,
  errorMessage,
  ErrorCodes
} from "@nzoth/bridge"
import { innerAppData } from "../../app"

function parseURL(url: string) {
  const [path, query] = url.split("?")
  return {
    path,
    query: queryToObject(query)
  }
}

function queryToObject(queryString: string) {
  const query: Record<string, any> = {}

  const pl = /\+/g
  function decode(s: string) {
    return decodeURIComponent(s.replace(pl, " "))
  }

  const search = /([^&=]+)=?([^&]*)/g

  let match: RegExpExecArray | null
  while ((match = search.exec(queryString))) {
    query[decode(match[1])] = decode(match[2])
  }
  return query
}

export function pathIsTabBar(path: string) {
  if (globalThis.__NZConfig.tabBar) {
    return (
      globalThis.__NZConfig.tabBar.list.find(item => {
        return item.path == path
      }) !== undefined
    )
  }
  return false
}

export function pathIsExist(path: string) {
  return (
    globalThis.__NZConfig.pages.find(page => {
      return page.path === path
    }) !== undefined
  )
}

const enum Events {
  NAVIGATE_TO = "navigateTo",
  NAVIGATE_BACK = "navigateBack",
  REDIRECT_TO = "redirectTo",
  RE_LAUNCH = "reLaunch",
  SWITCH_TAB = "switchTab"
}

interface NavigateToOptions {
  url: string
  success?: NavigateToSuccessCallback
  fail?: NavigateToFailCallback
  complete?: NavigateToCompleteCallback
}

type NavigateToSuccessCallback = (res: GeneralCallbackResult) => void

type NavigateToFailCallback = (res: GeneralCallbackResult) => void

type NavigateToCompleteCallback = (res: GeneralCallbackResult) => void

export function navigateTo<T extends NavigateToOptions = NavigateToOptions>(
  options: T
): AsyncReturn<T, NavigateToOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.NAVIGATE_TO
    if (innerAppData.routerLock) {
      invokeFailure(
        Events.NAVIGATE_TO,
        options,
        "防止重复多次打开页面，需要在新页面打开完成后才能调用。"
      )
      return
    }

    if (!options.url) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "url"))
      return
    }

    const { path, query } = parseURL(options.url)

    if (pathIsTabBar(path)) {
      invokeFailure(event, options, "cannot navigate to tabbar page")
      return
    }

    if (!pathIsExist(path)) {
      invokeFailure(event, options, `${options.url} is not found`)
      return
    }

    innerAppData.routerLock = true
    InnerJSBridge.invoke(event, options, result => {
      innerAppData.routerLock = false
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
      } else {
        innerAppData.query = query
        invokeSuccess(event, options, {})
      }
    })
  }, options)
}

interface NavigateBackOptions {
  delta?: number
  success?: NavigateBackSuccessCallback
  fail?: NavigateBackFailCallback
  complete?: NavigateBackCompleteCallback
}

type NavigateBackSuccessCallback = (res: GeneralCallbackResult) => void

type NavigateBackFailCallback = (res: GeneralCallbackResult) => void

type NavigateBackCompleteCallback = (res: GeneralCallbackResult) => void

export function navigateBack<T extends NavigateBackOptions = NavigateBackOptions>(
  options: T
): AsyncReturn<T, NavigateBackOptions> {
  return wrapperAsyncAPI(
    options => {
      const event = Events.NAVIGATE_BACK
      if (innerAppData.routerLock) {
        invokeFailure(event, options, "防止重复多次打开页面，需要在新页面打开完成后才能调用。")
        return
      }

      innerAppData.routerLock = true
      InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
        innerAppData.routerLock = false
        invokeCallback(event, options, result)
      })
    },
    options,
    { delta: 1 }
  )
}

interface RedirectToOptions {
  url: string
  success?: RedirectToSuccessCallback
  fail?: RedirectToFailCallback
  complete?: RedirectToCompleteCallback
}

type RedirectToSuccessCallback = (res: GeneralCallbackResult) => void

type RedirectToFailCallback = (res: GeneralCallbackResult) => void

type RedirectToCompleteCallback = (res: GeneralCallbackResult) => void

export function redirectTo<T extends RedirectToOptions = RedirectToOptions>(
  options: T
): AsyncReturn<T, RedirectToOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.REDIRECT_TO
    if (!options.url) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "url"))
      return
    }

    const { path, query } = parseURL(options.url)

    if (pathIsTabBar(path)) {
      invokeFailure(event, options, "cannot redirectTo tabbar page")
      return
    }

    if (!pathIsExist(path)) {
      invokeFailure(event, options, `${options.url} is not found`)
      return
    }

    InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
      } else {
        innerAppData.query = query
        invokeSuccess(event, options, {})
      }
    })
  }, options)
}

interface ReLaunchOptions {
  url: string
  success?: ReLaunchSuccessCallback
  fail?: ReLaunchFailCallback
  complete?: ReLaunchCompleteCallback
}

type ReLaunchSuccessCallback = (res: GeneralCallbackResult) => void

type ReLaunchFailCallback = (res: GeneralCallbackResult) => void

type ReLaunchCompleteCallback = (res: GeneralCallbackResult) => void

export function reLaunch<T extends ReLaunchOptions = ReLaunchOptions>(
  options: T
): AsyncReturn<T, ReLaunchOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.RE_LAUNCH
    if (!options.url) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "url"))
      return
    }

    const { path, query } = parseURL(options.url)

    const exist = globalThis.__NZConfig.pages.find(page => {
      return page.path === path
    })

    if (exist === undefined) {
      invokeFailure(event, options, `${options.url} is not found`)
      return
    }

    InnerJSBridge.invoke<SuccessResult<T>>(event, options, result => {
      if (result.errMsg) {
        invokeFailure(event, options, result.errMsg)
      } else {
        innerAppData.query = query
        invokeSuccess(event, options, {})
      }
    })
  }, options)
}

interface SwitchTabOptions {
  url: string
  success?: SwitchTabSuccessCallback
  fail?: SwitchTabFailCallback
  complete?: SwitchTabCompleteCallback
}

type SwitchTabSuccessCallback = (res: GeneralCallbackResult) => void

type SwitchTabFailCallback = (res: GeneralCallbackResult) => void

type SwitchTabCompleteCallback = (res: GeneralCallbackResult) => void

export function switchTab<T extends SwitchTabOptions = SwitchTabOptions>(
  options: T
): AsyncReturn<T, SwitchTabOptions> {
  return wrapperAsyncAPI(options => {
    const event = Events.SWITCH_TAB
    if (!options.url) {
      invokeFailure(event, options, errorMessage(ErrorCodes.MISSING_REQUIRED_PRAMAR, "url"))
      return
    }

    if (globalThis.__NZConfig.tabBar) {
      const { path } = parseURL(options.url)
      const exist = globalThis.__NZConfig.tabBar.list.find(item => {
        return item.path === path
      })
      if (exist === undefined) {
        invokeFailure(event, options, `${path} is not found`)
        return
      }
      InnerJSBridge.invoke<SuccessResult<T>>(event, { url: path }, result => {
        invokeCallback(event, options, result)
      })
    } else {
      invokeFailure(event, options, `app.config tabBar undefined`)
      return
    }
  }, options)
}
