import { env } from "@evoker/bridge"
import {
  getWindowInfo,
  getAppBaseInfo,
  getDeviceInfo,
  getSystemSetting,
  getAppAuthorizeSetting,
  getSystemInfo,
  getSystemInfoAsync,
  getSystemInfoSync
} from "./api/base/system"
import { base64ToArrayBuffer, arrayBufferToBase64 } from "./api/base/base64"
import { navigateTo, navigateBack, redirectTo, reLaunch, switchTab } from "./api/route"
import { navigateToMiniProgram, exitMiniProgram } from "./api/navigate"
import {
  getStorage,
  getStorageSync,
  setStorage,
  setStorageSync,
  removeStorage,
  removeStorageSync,
  clearStorage,
  clearStorageSync,
  getStorageInfo,
  getStorageInfoSync
} from "@evoker/bridge"
import {
  showModal,
  showToast,
  showLoading,
  showActionSheet,
  hideLoading,
  hideToast
} from "@evoker/bridge"
import {
  setNavigationBarTitle,
  showNavigationBarLoading,
  hideNavigationBarLoading,
  setNavigationBarColor,
  hideHomeButton,
  hideCapsule
} from "@evoker/bridge"
import { startPullDownRefresh, stopPullDownRefresh } from "@evoker/bridge"
import {
  previewImage,
  chooseImage,
  saveImageToPhotosAlbum,
  getImageInfo,
  compressImage,
  chooseVideo,
  saveVideoToPhotosAlbum,
  getVideoInfo,
  compressVideo
} from "@evoker/bridge"
import { createCameraContext } from "./api/media/camera"
import { createInnerAudioContext, setInnerAudioOption } from "@evoker/bridge"
import { vibrateShort, vibrateLong } from "@evoker/bridge"
import {
  getNetworkType,
  getLocalIPAddress,
  onNetworkStatusChange,
  offNetworkStatusChange
} from "@evoker/bridge"
import { scanCode } from "@evoker/bridge"
import {
  getScreenBrightness,
  setScreenBrightness,
  onUserCaptureScreen,
  offUserCaptureScreen,
  setKeepScreenOn
} from "@evoker/bridge"
import { getClipboardData, setClipboardData } from "@evoker/bridge"
import { makePhoneCall } from "@evoker/bridge"
import { getRandomValues, rsa } from "@evoker/bridge"
import { createSelectorQuery } from "./api/html/selector"
import { getBatteryInfo } from "@evoker/bridge"
import { onKeyboardHeighChange, offKeyboardHeighChange, hideKeyboard } from "@evoker/bridge"
import {
  setTabBarBadge,
  hideTabBarRedDot,
  setTabBarItem,
  setTabBarStyle,
  showTabBarRedDot,
  removeTabBarBadge
} from "@evoker/bridge"
import {
  request,
  downloadFile,
  uploadFile,
  connectSocket,
  sendSocketMessage,
  closeSocket,
  onSocketOpen,
  onSocketClose,
  onSocketError,
  OnSocketMessage
} from "./api/request"
import { createAnimation } from "./api/ui/animation"
import { pageScrollTo } from "./api/ui/scroll"
import { loadFontFace } from "./api/ui/font"
import {
  getLocation,
  startLocationUpdate,
  stopLocationUpdate,
  onLocationChange,
  offLocationChange,
  onLocationChangeError,
  offLocationChangeError
} from "@evoker/bridge"
import { getRecorderManager } from "@evoker/bridge"
import { getSetting, authorize } from "@evoker/bridge"
import { getUserProfile, getUserInfo } from "./api/open"
import { openSetting } from "./api/auth"
import { login, checkSession } from "@evoker/bridge"
import { showTabBar, hideTabBar } from "../bridge/api/ui/tabBar"
import { createIntersectionObserver } from "./api/html/intersection"
import {
  onShow,
  offShow,
  onHide,
  offHide,
  onError,
  offError,
  onThemeChange,
  offThemeChange,
  onAudioInterruptionBegin,
  offAudioInterruptionBegin,
  onAudioInterruptionEnd,
  offAudioInterruptionEnd
} from "../lifecycle/global"
import { showShareMenu, hideShareMenu } from "./api/share"
import {
  saveFile,
  removeSavedFile,
  getSavedFileList,
  getSavedFileInfo,
  getFileInfo,
  getFileSystemManager
} from "@evoker/bridge"
import "./fromWebView"

export type { VideoContext } from "./api/media/video"

export type { SocketTask } from "./api/request"

export default {
  env,
  base64ToArrayBuffer,
  arrayBufferToBase64,
  navigateTo,
  navigateBack,
  redirectTo,
  switchTab,
  reLaunch,
  getStorage,
  getStorageSync,
  setStorage,
  setStorageSync,
  removeStorage,
  removeStorageSync,
  clearStorage,
  clearStorageSync,
  getStorageInfo,
  getStorageInfoSync,
  showModal,
  setNavigationBarTitle,
  showNavigationBarLoading,
  hideNavigationBarLoading,
  setNavigationBarColor,
  hideHomeButton,
  hideCapsule,
  previewImage,
  saveImageToPhotosAlbum,
  getImageInfo,
  chooseImage,
  compressImage,
  chooseVideo,
  saveVideoToPhotosAlbum,
  getVideoInfo,
  compressVideo,
  request,
  downloadFile,
  uploadFile,
  connectSocket,
  sendSocketMessage,
  closeSocket,
  onSocketOpen,
  onSocketClose,
  onSocketError,
  OnSocketMessage,
  showLoading,
  hideLoading,
  showToast,
  hideToast,
  startPullDownRefresh,
  stopPullDownRefresh,
  showActionSheet,
  vibrateShort,
  vibrateLong,
  getRandomValues,
  rsa,
  getWindowInfo,
  getAppAuthorizeSetting,
  navigateToMiniProgram,
  exitMiniProgram,
  createCameraContext,
  createInnerAudioContext,
  setInnerAudioOption,
  getAppBaseInfo,
  getDeviceInfo,
  getSystemSetting,
  getSystemInfo,
  getSystemInfoAsync,
  getSystemInfoSync,
  createSelectorQuery,
  getBatteryInfo,
  onKeyboardHeighChange,
  offKeyboardHeighChange,
  hideKeyboard,
  getNetworkType,
  getLocalIPAddress,
  scanCode,
  getScreenBrightness,
  setScreenBrightness,
  showTabBar,
  hideTabBar,
  setTabBarBadge,
  hideTabBarRedDot,
  setTabBarItem,
  setTabBarStyle,
  showTabBarRedDot,
  removeTabBarBadge,
  getClipboardData,
  setClipboardData,
  makePhoneCall,
  onNetworkStatusChange,
  offNetworkStatusChange,
  onUserCaptureScreen,
  offUserCaptureScreen,
  setKeepScreenOn,
  createAnimation,
  pageScrollTo,
  loadFontFace,
  getLocation,
  startLocationUpdate,
  stopLocationUpdate,
  onLocationChange,
  offLocationChange,
  onLocationChangeError,
  offLocationChangeError,
  getRecorderManager,
  getSetting,
  openSetting,
  authorize,
  getUserProfile,
  getUserInfo,
  login,
  checkSession,
  createIntersectionObserver,
  onShow,
  offShow,
  onHide,
  offHide,
  onError,
  offError,
  onThemeChange,
  offThemeChange,
  onAudioInterruptionBegin,
  offAudioInterruptionBegin,
  onAudioInterruptionEnd,
  offAudioInterruptionEnd,
  showShareMenu,
  hideShareMenu,
  saveFile,
  removeSavedFile,
  getSavedFileList,
  getSavedFileInfo,
  getFileInfo,
  getFileSystemManager
}
