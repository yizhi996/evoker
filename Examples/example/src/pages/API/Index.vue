<template>
  <n-page-index desc="以下将展示小程序接口能力" :list="list"></n-page-index>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import NPageIndex from "../../components/NPageIndex.vue"

const list = reactive([
  {
    id: 'api',
    name: '开放接口',
    open: false,
    pages: [
      {
        name: '登录',
        url: 'login'
      }, {
        name: '获取用户信息',
        url: 'get-user-info'
      }, {
        name: '设置',
        url: 'setting'
      }
    ]
  },
  {
    id: 'page',
    name: '界面',
    open: false,
    pages: [
      {
        name: '设置界面标题',
        url: 'set-navigation-bar-title'
      }, {
        name: '标题栏加载动画',
        url: 'navigation-bar-loading'
      }, {
        name: '设置TabBar',
        url: '@set-tab-bar'
      }, {
        name: '页面跳转',
        url: 'navigator/navigator'
      }, {
        name: '下拉刷新',
        url: 'pull-down-refresh'
      }, {
        name: '创建动画',
        url: 'animation'
      }, {
        name: '创建绘画',
        url: 'canvas/canvas'
      }, {
        name: '显示操作菜单',
        url: 'action-sheet'
      }, {
        name: '显示模态弹窗',
        url: 'modal'
      }, {
        name: '页面滚动',
        url: 'page-scroll'
      }, {
        name: '显示消息提示框',
        url: 'toast'
      }, {
        name: '获取 HTML 节点信息',
        url: 'get-html-node-info'
      }, {
        name: 'HTML 节点布局相交状态',
        url: 'intersection-observer/intersection-observer'
      }
    ]
  }, {
    id: 'device',
    name: '设备',
    open: false,
    pages: [
      {
        name: '获取手机网络状态',
        url: 'get-network-type'
      }, {
        name: '监听手机网络变化',
        url: 'on-network-status-change'
      }, {
        name: '获取手机系统信息',
        url: 'get-system-info'
      }, {
        name: '获取手机设备电量',
        url: 'get-battery-info/get-battery-info'
      }, {
        name: '打电话',
        url: 'make-phone-call'
      }, {
        name: '扫码',
        url: 'scan-code'
      }, {
        name: '剪切板',
        url: 'clipboard'
      }, {
        name: '屏幕亮度',
        url: 'screen-brightness'
      }, {
        name: '用户截屏事件',
        url: 'capture-screen'
      }, {
        name: '振动',
        url: 'vibrate'
      }
    ]
  }, {
    id: 'performance',
    name: '性能',
    open: false,
    pages: [
      {
        name: '获取性能数据',
        url: 'get-performance/get-performance'
      }
    ]
  }, {
    id: 'network',
    name: '网络',
    open: false,
    pages: [
      {
        name: '发起一个请求',
        url: 'request'
      }, {
        name: 'WebSocket',
        url: 'web-socket/web-socket'
      }, {
        name: '上传文件',
        url: 'upload-file'
      }, {
        name: '下载文件',
        url: 'download-file'
      }
    ]
  }, {
    id: 'media',
    name: '媒体',
    open: false,
    pages: [
      {
        name: '图片',
        url: 'choose-image'
      }, {
        name: '音频',
        url: 'audio'
      }, {
        name: '录音',
        url: 'voice'
      }, {
        name: '背景音频',
        url: 'background-audio/background-audio'
      }, {
        name: '文件',
        url: 'file/file'
      }, {
        name: '视频',
        url: 'choose-video'
      }, {
        name: '音视频合成',
        url: 'media-container/media-container'
      }, {
        name: '动态加载字体',
        url: 'load-font-face'
      }
    ]
  }, {
    id: 'location',
    name: '位置',
    open: false,
    pages: [
      {
        name: '获取当前位置',
        url: 'get-location'
      }
    ]
  }, {
    id: 'storage',
    name: '数据',
    open: false,
    pages: [{
      name: '本地存储',
      url: 'storage'
    }],
  }, {
    id: 'framework',
    name: '框架',
    open: false,
    pages: [{
      name: '双向绑定 v-model',
      url: 'v-model',
    }, {
      name: '屏幕旋转',
      url: 'resizable/resizable'
    }]
  }
])

</script>
