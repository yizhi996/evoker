import JSBridge from "./bridge"
import { vibrateShort, vibrateLong, authorize, showModal } from "@evoker/bridge"
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
  pageScrollTo,
  authorize,
  showModal
}

export { JSBridge }
