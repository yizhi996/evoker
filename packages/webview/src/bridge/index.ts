import NZJSBridge from "./bridge"
import { vibrateShort, vibrateLong } from "@nzoth/bridge"
import {
  navigateTo,
  navigateBack,
  navigateToMiniProgram,
  switchTab,
  redirectTo,
  reLaunch,
  exit
} from "./api/navigator"
import "./service"

export {
  vibrateShort,
  vibrateLong,
  navigateTo,
  navigateBack,
  navigateToMiniProgram,
  switchTab,
  redirectTo,
  reLaunch,
  exit
}

export { NZJSBridge }
