import { invokeAppServiceMethod } from "../fromService"

export function navigateTo(url?: string) {
  url && invokeAppServiceMethod("navigateTo", { url })
}

export function redirectTo(url?: string) {
  url && invokeAppServiceMethod("redirectTo", { url })
}

export function switchTab(url?: string) {
  url && invokeAppServiceMethod("switchTab", { url })
}

export function reLaunch(url?: string) {
  url && invokeAppServiceMethod("reLaunch", { url })
}

export function navigateBack(delta: number = 1) {
  invokeAppServiceMethod("navigateBack", { delta })
}

export function exit() {
  invokeAppServiceMethod("exit", {})
}

export function navigateToMiniProgram(options: { appId: string; path?: string }) {
  invokeAppServiceMethod("navigateToMiniProgram", {
    appId: options.appId,
    path: options.path
  })
}
