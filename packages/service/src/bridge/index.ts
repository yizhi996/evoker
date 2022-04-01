import {
  getWindowInfo,
  getAppBaseInfo,
  getDeviceInfo,
  getSystemSetting,
  getSystemInfo,
  getSystemInfoAsync,
  getSystemInfoSync
} from "./api/base/system"
import {
  navigateTo,
  navigateBack,
  redirectTo,
  reLaunch,
  switchTab
} from "./api/route"
import { navigateToMiniProgram } from "@nzoth/bridge"
import {
  getStorage,
  setStorage,
  removeStorage,
  clearStorage,
  getStorageInfo
} from "@nzoth/bridge"
import {
  showModal,
  showToast,
  showLoading,
  showActionSheet,
  hideLoading,
  hideToast
} from "@nzoth/bridge"
import {
  setNavigationBarTitle,
  showNavigationBarLoading,
  hideNavigationBarLoading,
  setNavigationBarColor,
  hideHomeButton
} from "@nzoth/bridge"
import { startPullDownRefresh, stopPullDownRefresh } from "@nzoth/bridge"
import { previewImage, chooseImage } from "@nzoth/bridge"
import { createCameraContext } from "@nzoth/bridge"
import { createInnerAudioContext } from "@nzoth/bridge"
import { vibrateShort, vibrateLong } from "@nzoth/bridge"
import {
  getNetworkType,
  getLocalIPAddress,
  onNetworkStatusChange,
  offNetworkStatusChange
} from "@nzoth/bridge"
import { scanCode } from "@nzoth/bridge"
import {
  getScreenBrightness,
  setScreenBrightness,
  onUserCaptureScreen,
  offUserCaptureScreen
} from "@nzoth/bridge"
import { getClipboardData, setClipboardData } from "@nzoth/bridge"
import { makePhoneCall } from "@nzoth/bridge"
import { rsa } from "@nzoth/bridge"
import { createSelectorQuery } from "./api/html/selector"
import { getBatteryInfo } from "@nzoth/bridge"
import { showTabBar, hideTabBar } from "@nzoth/bridge"
import { request, downloadFile, uploadFile } from "./api/request"
import { createAnimation } from "./api/ui/animation"
import "./webview"

const env = { USER_DATA_PATH: "nzfile://usr" }

export {
  env,
  navigateTo,
  navigateBack,
  redirectTo,
  switchTab,
  reLaunch,
  getStorage,
  setStorage,
  removeStorage,
  clearStorage,
  getStorageInfo,
  showModal,
  setNavigationBarTitle,
  showNavigationBarLoading,
  hideNavigationBarLoading,
  setNavigationBarColor,
  hideHomeButton,
  previewImage,
  chooseImage,
  request,
  downloadFile,
  uploadFile,
  showLoading,
  hideLoading,
  showToast,
  hideToast,
  startPullDownRefresh,
  stopPullDownRefresh,
  showActionSheet,
  vibrateShort,
  vibrateLong,
  rsa,
  getWindowInfo,
  navigateToMiniProgram,
  createCameraContext,
  createInnerAudioContext,
  getAppBaseInfo,
  getDeviceInfo,
  getSystemSetting,
  getSystemInfo,
  getSystemInfoAsync,
  getSystemInfoSync,
  createSelectorQuery,
  getBatteryInfo,
  getNetworkType,
  getLocalIPAddress,
  scanCode,
  getScreenBrightness,
  setScreenBrightness,
  showTabBar,
  hideTabBar,
  getClipboardData,
  setClipboardData,
  makePhoneCall,
  onNetworkStatusChange,
  offNetworkStatusChange,
  onUserCaptureScreen,
  offUserCaptureScreen,
  createAnimation
}

export default {
  env,
  navigateTo,
  navigateBack,
  redirectTo,
  switchTab,
  reLaunch,
  getStorage,
  setStorage,
  removeStorage,
  clearStorage,
  getStorageInfo,
  showModal,
  setNavigationBarTitle,
  showNavigationBarLoading,
  hideNavigationBarLoading,
  setNavigationBarColor,
  hideHomeButton,
  previewImage,
  chooseImage,
  request,
  downloadFile,
  uploadFile,
  showLoading,
  hideLoading,
  showToast,
  hideToast,
  startPullDownRefresh,
  stopPullDownRefresh,
  showActionSheet,
  vibrateShort,
  vibrateLong,
  rsa,
  getWindowInfo,
  navigateToMiniProgram,
  createCameraContext,
  createInnerAudioContext,
  getAppBaseInfo,
  getDeviceInfo,
  getSystemSetting,
  getSystemInfo,
  getSystemInfoAsync,
  getSystemInfoSync,
  createSelectorQuery,
  getBatteryInfo,
  getNetworkType,
  getLocalIPAddress,
  scanCode,
  getScreenBrightness,
  setScreenBrightness,
  showTabBar,
  hideTabBar,
  getClipboardData,
  setClipboardData,
  makePhoneCall,
  onNetworkStatusChange,
  offNetworkStatusChange,
  onUserCaptureScreen,
  offUserCaptureScreen,
  createAnimation
}
