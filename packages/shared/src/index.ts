export * from "./event"
export { SyncFlags } from "./syncFlags"
export * from "./canvas"
export * from "./devtools"

export const isNumber = (val: unknown): val is number => typeof val === "number"

export const isBoolean = (val: unknown): val is number => typeof val === "boolean"

export const isArrayBuffer = (val: unknown) =>
  Object.prototype.toString.call(val) === "[object ArrayBuffer]"

export const clamp = (value: number, min: number, max: number) =>
  Math.min(Math.max(min, value), max)

export const isDevtools = __Config.platform === "devtools"
