import { invoke } from "../bridge"
import {
  invokeCallback,
  GeneralCallbackResult,
  AsyncReturn,
  SuccessResult,
  wrapperAsyncAPI,
  invokeSuccess,
  invokeFailure
} from "../async"

const enum Events {
  GET_SETTING = "getSetting",
  AUTHORIZE = "authorize",
  GET_AUTHORIZE = "getAuthorize",
  SET_AUTHORIZE = "setAuthorize",
  OPEN_AUTHORIZATION_VIEW = "openAuthorizationView"
}

export interface AuthSetting {
  [x: string]: boolean
  "scope.userInfo": boolean
  "scope.userLocation": boolean
  "scope.record": boolean
  "scope.writePhotosAlbum": boolean
  "scope.camera": boolean
}

interface GetSettingOptions {
  success?: GetSettingSuccessCallback
  fail?: GetSettingFailCallback
  complete?: GetSettingCompleteCallback
}

interface GetSettingSuccessCallbackResult {
  authSetting: AuthSetting
}

type GetSettingSuccessCallback = (res: GetSettingSuccessCallbackResult) => void

type GetSettingFailCallback = (res: GeneralCallbackResult) => void

type GetSettingCompleteCallback = (res: GeneralCallbackResult) => void

export function getSetting<T extends GetSettingOptions = GetSettingOptions>(
  options: T
): AsyncReturn<T, GetSettingOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.GET_SETTING, {}, result => {
      invokeCallback(Events.GET_SETTING, options, result)
    })
  }, options)
}

interface AuthorizeOptions {
  scope: string
  success?: AuthorizeSuccessCallback
  fail?: AuthorizeFailCallback
  complete?: AuthorizeCompleteCallback
}

type AuthorizeSuccessCallback = (res: GeneralCallbackResult) => void

type AuthorizeFailCallback = (res: GeneralCallbackResult) => void

type AuthorizeCompleteCallback = (res: GeneralCallbackResult) => void

export function authorize<T extends AuthorizeOptions = AuthorizeOptions>(
  options: T
): AsyncReturn<T, AuthorizeOptions> {
  return wrapperAsyncAPI<T>(options => {
    requestAuthorization(options.scope)
      .then(() => {
        invokeSuccess(Events.AUTHORIZE, options, {})
      })
      .catch(error => {
        invokeFailure(Events.AUTHORIZE, options, error)
      })
  }, options)
}

export function openAuthorizationView(scope: string): Promise<boolean> {
  let title = ""
  switch (scope) {
    case "scope.userInfo":
      title = "获取你的昵称、头像"
      break
    case "scope.userLocation":
      title = "使用你的定位"
      break
    case "scope.record":
      title = "使用你的麦克风"
      break
    case "scope.writePhotosAlbum":
      title = "允许保存图片至相册"
      break
    case "scope.camera":
      title = "使用你的摄像头"
      break
  }

  if (title === "") {
    return Promise.reject("scope invalid")
  }

  return new Promise((resolve, reject) => {
    const { appName, appIcon = "" } = globalThis.__NZConfig
    invoke<{ authorized: boolean }>(
      Events.OPEN_AUTHORIZATION_VIEW,
      { appName, appIcon, title },
      result => {
        if (result.errMsg) {
          reject(result.errMsg)
        } else {
          resolve(result.data!.authorized)
        }
      }
    )
  })
}

export const enum AuthorizationStatus {
  authorized = 0,
  denied,
  notDetermined
}

export function getAuthorize(scope: string): Promise<AuthorizationStatus> {
  return new Promise((resolve, reject) => {
    invoke<{ status: AuthorizationStatus }>(
      Events.GET_AUTHORIZE,
      { scope },
      result => {
        if (result.errMsg) {
          reject(result.errMsg)
        } else {
          resolve(result.data!.status)
        }
      }
    )
  })
}

export function setAuthorize(
  scope: string,
  authorized: boolean
): Promise<void> {
  return new Promise((resolve, reject) => {
    invoke(Events.SET_AUTHORIZE, { scope, authorized }, result => {
      if (result.errMsg) {
        reject(result.errMsg)
      } else {
        resolve()
      }
    })
  })
}

export function requestAuthorization(
  scope: string,
  once: boolean = true
): Promise<void> {
  return new Promise(async (reslove, reject) => {
    try {
      const status = await getAuthorize(scope)
      if (status === AuthorizationStatus.authorized) {
        reslove()
      } else if (status === AuthorizationStatus.denied && once) {
        reject(`${scope} auth denied`)
      } else {
        const authorized = await openAuthorizationView(scope)
        if (authorized) {
          reslove()
        } else {
          reject(`${scope} auth denied`)
        }
        setAuthorize(scope, authorized)
      }
    } catch (error) {
      reject(`${scope} ${error}`)
    }
  })
}
