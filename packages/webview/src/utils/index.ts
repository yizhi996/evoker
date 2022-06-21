import { isString } from "@vue/shared"

export function isTrue(value: string | boolean | null): boolean {
  if (isString(value)) {
    const s = value.toLowerCase()
    return s === "" || s === "true"
  }
  if (value) {
    return value
  }
  return false
}
