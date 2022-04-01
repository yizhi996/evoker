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
import { pageScrollTo } from "./api/scroll"
import "./fromService"

export {
  vibrateShort,
  vibrateLong,
  navigateTo,
  navigateBack,
  navigateToMiniProgram,
  switchTab,
  redirectTo,
  reLaunch,
  exit,
  pageScrollTo
}

export { NZJSBridge }
