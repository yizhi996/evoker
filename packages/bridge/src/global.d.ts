interface NZAppServiceNativeSDK {}

declare global {
  interface Window {
    webViewId: number
    webkit?: any
    __NZAppServiceNativeSDK: NZAppServiceNativeSDK
  }
}

export {}
