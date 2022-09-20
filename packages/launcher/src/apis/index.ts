import { getAppVersion, updateApp } from "../bridge"
import { useLocalStore, App, EnvVersion } from "../storage"
import { isEqualApp } from "../utils"

interface ErrorResponse {
  errCode: number
  errMsg: string
}

export function request<T>(method: string, url: string, data: Record<string, any>) {
  return new Promise<T>((resolve, reject) => {
    ek.request({
      method: method as any,
      url,
      data,
      success: res => {
        const data = res.data as T & ErrorResponse
        if (data.errCode) {
          reject(data)
        } else {
          resolve(data)
        }
      },
      fail: reject
    })
  })
}

export function download(url: string) {
  return new Promise<string>((resolve, reject) => {
    ek.downloadFile({
      url,
      success: res => {
        resolve(res.tempFilePath)
      },
      fail: reject
    })
  })
}

export async function subscribe(
  baseURL: string,
  appId: string,
  envVersion: EnvVersion = EnvVersion.RELEASE
) {
  try {
    ek.showLoading({ title: "Loading", mask: true })
    const storage = useLocalStore()
    const res = await request<App>("GET", baseURL + "/cloud/api/app/subscribe", {
      appId,
      envVersion
    })
    res.url = baseURL
    const finding = { appId, envVersion }
    const i = storage.apps.findIndex(a => isEqualApp(a, finding))
    if (i > -1) {
      storage.apps[i] = res
    } else {
      storage.apps.push(res)
    }
    storage.saveLocalApps()

    await update(baseURL, appId, envVersion)
    ek.hideLoading()
  } catch (e) {
    ek.showToast({ title: e.errMsg, icon: "none" })
  }
}

interface UpdateResponseData {
  update: boolean
  files: Record<string, string>
  version: string
}

export async function update(
  baseURL: string,
  appId: string,
  envVersion: EnvVersion = EnvVersion.RELEASE
) {
  const { version } = await getAppVersion({ appId, envVersion })
  const info = ek.getAppBaseInfo()
  info.nativeSDKVersion
  const storage = useLocalStore()
  const res = await request<UpdateResponseData>("POST", baseURL + "/cloud/api/app/update", {
    appId,
    envVersion,
    version,
    nativeSDKVersion: info.nativeSDKVersion
  })
  if (res.update) {
    const mainPakcageURL = res.files["main"]
    if (mainPakcageURL) {
      const tempFilePath = await download(mainPakcageURL)
      await updateApp({
        appId,
        envVersion,
        version: res.version,
        filePath: tempFilePath
      })
      console.log("11")
      const finding = { appId, envVersion }
      const i = storage.apps.findIndex(a => isEqualApp(a, finding))
      if (i > -1) {
        storage.apps[i].version = res.version
        storage.saveLocalApps()
      }
    }
  }
  console.log(22)
  return res.update
}
