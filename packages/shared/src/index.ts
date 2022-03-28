export * from "./tag"
export * from "./event"
export * from "./syncFlags"

export function isString(val: unknown): val is string {
  return typeof val === "string"
}

export function isNumber(val: unknown): val is number {
  return typeof val === "number"
}

export function isBoolean(val: unknown): val is boolean {
  return typeof val === "boolean"
}

export function isFunction(val: unknown): val is Function {
  return typeof val === "function"
}

export function isObject(val: unknown): val is Record<any, any> {
  return val !== null && typeof val === "object"
}

export function isArrayBuffer(val: unknown) {
  return Object.prototype.toString.call(val) === "[object ArrayBuffer]"
}
