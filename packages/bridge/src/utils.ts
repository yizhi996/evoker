import { isPlainObject } from "@vue/shared"

export function combineOptions<T = Record<string, any>, U = Record<string, any>>(
  options: T,
  preset: U
): T & U {
  const res: Record<string, any> = preset
  for (const key in options) {
    const value = options[key]
    if (value != null) {
      res[key] = isPlainObject(value)
        ? combineOptions(value, (preset as Record<string, any>)[key])
        : value
    } else {
      res[key] = (preset as Record<string, any>)[key]
    }
  }
  return res as T & U
}

export function fetchArrayBuffer(data: any, key: string) {
  const { __arrayBuffer__ } = data
  if (__arrayBuffer__) {
    delete data.__arrayBuffer__

    const arrayBuffer = globalThis.__ArrayBufferRegister.get(__arrayBuffer__)
    data[key] = arrayBuffer
  }
}
