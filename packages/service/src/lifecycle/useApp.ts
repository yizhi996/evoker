import { LifecycleHooks, createHook } from "./hooks"

export type AppLaunchCallback = (options: AppLaunchOptions) => void

interface AppLaunchReferrerInfo {
  appId?: string
  extarData?: Record<string, any>
}

export interface AppLaunchOptions {
  path: string
  query: Record<string, any>
  referrerInfo: AppLaunchReferrerInfo
}

export type AppShowCallback = (options: AppShowOptions) => void

export interface AppShowOptions {
  path: string
  query: Record<string, any>
  referrerInfo: AppLaunchReferrerInfo
}

export type AppHideCallback = () => void

export type AppErrorCallback = (error: string) => void

export type AppThemeChangeCallback = (res: AppThemeChangeResult) => void

export interface AppThemeChangeResult {
  theme: "light" | "dark"
}

export default function useApp() {
  return {
    onLaunch: (hook: AppLaunchCallback) => {
      return createHook(LifecycleHooks.APP_ON_LAUNCH, hook)
    },
    onShow: (hook: AppShowCallback) => {
      return createHook(LifecycleHooks.APP_ON_SHOW, hook)
    },
    onHide: (hook: AppHideCallback) => {
      return createHook(LifecycleHooks.APP_ON_HIDE, hook)
    },
    onError: (hook: AppErrorCallback) => {
      return createHook(LifecycleHooks.APP_ON_ERROR, hook)
    },
    onThemeChange: (hook: AppThemeChangeCallback) => {
      return createHook(LifecycleHooks.APP_THEME_CHANGE, hook)
    }
  }
}
