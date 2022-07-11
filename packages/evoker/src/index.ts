import { global } from "@evoker/service"
import { getApp, getCurrentPages } from "@evoker/service"

export * from "@evoker/service"

globalThis.ek = global

globalThis.getApp = getApp

globalThis.getCurrentPages = getCurrentPages
