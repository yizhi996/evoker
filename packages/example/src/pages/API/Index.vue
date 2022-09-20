<template>
  <n-page-index desc="以下将展示小程序接口能力" :list="list"></n-page-index>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import NPageIndex from "../../components/NPageIndex.vue"

const list = reactive([
  {
    id: "api",
    name: "开放接口",
    open: false,
    pages: [
      { name: "登录", url: "./Login" },
      { name: "获取用户信息", url: "./GetUserInfo" },
      { name: "设置", url: "./Setting" }
    ]
  },
  {
    id: "page",
    name: "界面",
    open: false,
    pages: [
      { name: "设置界面标题", url: "./SetTitle" },
      { name: "标题栏加载动画", url: "./NavigationBarLoading" },
      { name: "设置TabBar", url: "@set-tab-bar" },
      { name: "页面跳转", url: "./Navigator" },
      { name: "下拉刷新", url: "./PullDownRefresh" },
      { name: "创建动画", url: "./Animation" },
      { name: "显示操作菜单", url: "./ActionSheet" },
      { name: "显示模态弹窗", url: "./Modal" },
      { name: "页面滚动", url: "./PageScroll" },
      { name: "显示消息提示框", url: "./Toast" },
      { name: "获取 HTML 节点信息", url: "./HTML" },
      { name: "HTML 节点布局相交状态", url: "./IntersectionObserver" }
    ]
  },
  {
    id: "device",
    name: "设备",
    open: false,
    pages: [
      { name: "获取手机网络状态", url: "./GetNetworkType" },
      { name: "监听手机网络变化", url: "./OnNetworkStatusChange" },
      { name: "获取手机系统信息", url: "./GetSystemInfo" },
      { name: "获取手机设备电量", url: "./GetBatteryInfo" },
      { name: "打电话", url: "./MakePhoneCall" },
      { name: "扫码", url: "./ScanCode" },
      { name: "剪切板", url: "./Clipboard" },
      { name: "屏幕亮度", url: "./ScreenBrightness" },
      { name: "用户截屏事件", url: "./CaptureScreen" },
      { name: "振动", url: "./Vibrate" }
    ]
  },
  {
    id: "network",
    name: "网络",
    open: false,
    pages: [
      { name: "发起一个请求", url: "./Request" },
      { name: "上传文件", url: "./UploadFile" },
      { name: "下载文件", url: "./DownloadFile" },
      { name: "WebSocket", url: "./WebSocket" }
    ]
  },
  {
    id: "media",
    name: "媒体",
    open: false,
    pages: [
      { name: "图片", url: "./Image" },
      { name: "音频", url: "./Audio" },
      { name: "录音", url: "./Voice" },
      { name: "背景音频", url: "not supported" },
      { name: "文件", url: "./File" },
      { name: "视频", url: "./Video" },
      { name: "动态加载字体", url: "./LoadFontFace" }
    ]
  },
  {
    id: "location",
    name: "位置",
    open: false,
    pages: [{ name: "获取当前位置", url: "./GetLocation" }]
  },
  {
    id: "storage",
    name: "数据",
    open: false,
    pages: [{ name: "本地存储", url: "./Storage" }]
  },
  {
    id: "framework",
    name: "框架",
    open: false,
    pages: [{ name: "双向绑定 v-model", url: "./VModel" }]
  }
])
</script>
