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
  OPEN_SETTING = "openSetting",
  AUTHORIZE = "authorize",
  GET_AUTHORIZE = "getAuthorize",
  SET_AUTHORIZE = "setAuthorize",
  OPEN_AUTHORIZATION_VIEW = "openAuthorizationView"
}

interface AuthSetting {
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

interface OpenSettingOptions {
  success?: OpenSettingSuccessCallback
  fail?: OpenSettingFailCallback
  complete?: OpenSettingCompleteCallback
}

interface OpenSettingSuccessCallbackResult {
  authSetting: AuthSetting
}

type OpenSettingSuccessCallback = (
  res: OpenSettingSuccessCallbackResult
) => void

type OpenSettingFailCallback = (res: GeneralCallbackResult) => void

type OpenSettingCompleteCallback = (res: GeneralCallbackResult) => void

export function openSetting<T extends OpenSettingOptions = OpenSettingOptions>(
  options: T
): AsyncReturn<T, OpenSettingOptions> {
  return wrapperAsyncAPI<T>(options => {
    invoke<SuccessResult<T>>(Events.OPEN_SETTING, {}, result => {
      invokeCallback(Events.OPEN_SETTING, options, result)
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
  return wrapperAsyncAPI<T>(async options => {
    try {
      const status = await getAuthorize(options.scope)
      if (status === AuthorizationStatus.authorized) {
        invokeSuccess(Events.AUTHORIZE, options, {})
      } else if (status === AuthorizationStatus.denied) {
        invokeFailure(Events.AUTHORIZE, options, options.scope + " denied")
      } else {
        const authorized = await openAuthorizationView(options.scope)
        if (authorized) {
          invokeSuccess(Events.AUTHORIZE, options, {})
        } else {
          invokeFailure(Events.AUTHORIZE, options, options.scope + " denied")
        }
        setAuthorize(options.scope, authorized)
      }
    } catch (error) {
      invokeFailure(Events.AUTHORIZE, options, options.scope + error)
    }
  }, options)
}

function openAuthorizationView(scope: string): Promise<boolean> {
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

function getAuthorize(scope: string): Promise<AuthorizationStatus> {
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

function setAuthorize(scope: string, authorized: boolean): Promise<void> {
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
