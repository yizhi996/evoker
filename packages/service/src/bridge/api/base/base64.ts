export function base64ToArrayBuffer(string: string): ArrayBuffer {
  return globalThis.__Base64.base64ToArrayBuffer(string)
}

export function arrayBufferToBase64(buffer: ArrayBuffer): string {
  return globalThis.__Base64.arrayBufferToBase64(buffer)
}
