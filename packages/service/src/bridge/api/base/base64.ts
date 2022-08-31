/** 将 Base64 字符串转成 ArrayBuffer 对象 */
export function base64ToArrayBuffer(
  /** 要转化成 ArrayBuffer 对象的 Base64 字符串 */
  string: string
): ArrayBuffer {
  return globalThis.__Base64.base64ToArrayBuffer(string)
}

/** 将 ArrayBuffer 对象转成 Base64 字符串 */
export function arrayBufferToBase64(
  /** 要转换成 Base64 字符串的 ArrayBuffer 对象 */
  buffer: ArrayBuffer
): string {
  return globalThis.__Base64.arrayBufferToBase64(buffer)
}
