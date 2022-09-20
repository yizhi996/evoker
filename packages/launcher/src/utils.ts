import parse from "url-parse"
import { EnvVersion } from "./storage"

export function parseURL(urlstr: string) {
  return parse(urlstr, true)
}

export function isWebSocketURL(urlstr: string) {
  return parseURL(urlstr).protocol === "ws:"
}

export function isEqualApp<T extends { appId: string; envVersion: EnvVersion }>(lhs: T, rhs: T) {
  return lhs.appId === rhs.appId && lhs.envVersion === rhs.envVersion
}
