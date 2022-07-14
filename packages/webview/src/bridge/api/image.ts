import JSBridge from "../bridge"

export function getLocalImage(src: string): Promise<string> {
  return new Promise((reslove, reject) => {
    JSBridge.invoke<{ src: string }>("getLocalImage", { path: src }, result => {
      if (result.errMsg) {
        reject(result.errMsg)
      } else {
        reslove(result.data!.src)
      }
    })
  })
}
