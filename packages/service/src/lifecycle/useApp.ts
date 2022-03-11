import { LifecycleHooks, createHook } from "./hooks"
import { decodeURL } from "../router"

interface AppLaunchOptions {
  path: string
  query: Record<string, any>
}

interface AppShowOptions {
  path: string
  query: Record<string, any>
}

export default function useApp() {
  return {
    onLaunch: (hook: (options: AppLaunchOptions) => void) => {
      return createHook(
        LifecycleHooks.APP_ON_LAUNCH,
        (message: { path: string }) => {
          hook(decodeURL(message.path))
        }
      )
    },
    onShow: (hook: (options: AppShowOptions) => void) => {
      return createHook(
        LifecycleHooks.APP_ON_SHOW,
        (message: { path: string }) => {
          hook(decodeURL(message.path))
        }
      )
    },
    onHide: (hook: () => void) => {
      return createHook(LifecycleHooks.APP_ON_HIDE, hook)
    }
  }
}
