import { InnerJSBridge } from "../bridge/bridge"
import { LifecycleHooks } from "./hooks"
import { addEvent, removeEvent, dispatchEvent } from "@nzoth/shared"
import type { AppErrorCallback, AppThemeChangeCallback } from "./useApp"

export function invokeAppOnError(error: unknown) {
  InnerJSBridge.subscribeHandler(LifecycleHooks.APP_ON_ERROR, error)
}

export function onError(callback: AppErrorCallback) {
  addEvent(LifecycleHooks.APP_ON_ERROR, callback)
}

export function offError(callback: AppErrorCallback) {
  removeEvent(LifecycleHooks.APP_ON_ERROR, callback)
}

export function onThemeChange(callback: AppThemeChangeCallback) {
  addEvent(LifecycleHooks.APP_THEME_CHANGE, callback)
}

export function offThemeChange(callback: AppThemeChangeCallback) {
  removeEvent(LifecycleHooks.APP_THEME_CHANGE, callback)
}
