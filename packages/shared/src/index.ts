export * from "./tag"
export * from "./event"
export * from "@vue/shared"
export { SyncFlags } from "./syncFlags"

export function isNumber(val: unknown): val is number {
  return typeof val === "number"
}

export function isBoolean(val: unknown): val is boolean {
  return typeof val === "boolean"
}

export function isArrayBuffer(val: unknown) {
  return Object.prototype.toString.call(val) === "[object ArrayBuffer]"
}

export function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(min, value), max)
}
