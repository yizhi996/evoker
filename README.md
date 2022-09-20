<p align="center">
  <img src="https://user-images.githubusercontent.com/10255725/191271816-5b937328-eb00-4941-9854-ee217af407d8.svg" alt="logo" width="180"/>
</p>
<br/>
<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2011-lightgrey?style=flat-square" alt="platform">
  <a href="https://www.npmjs.com/package/evoker"><img src="https://img.shields.io/npm/v/evoker?style=flat-square" alt="npm"></a>
  <img src="https://img.shields.io/cocoapods/v/Evoker?color=blue&style=flat-square" alt="Cocoapods">
</p>
<br/>

# Evoker
 
小程序引擎（开发中）

<img src="https://user-images.githubusercontent.com/10255725/191271152-ea971aaf-7a21-4d5e-b976-2e754cff2db5.gif" alt="launcher" width="180"/>

## Documentation

[evokerdev.com](https://evokerdev.com)

## Packages

| Package                                                                                      | desc                    |
| -------------------------------------------------------------------------------------------- | ----------------------- |
| [evoker](https://github.com/yizhi996/evoker/tree/main/packages/evoker)                       | 最终产物                |
| [@evoker/bridge](https://github.com/yizhi996/evoker/tree/main/packages/bridge)               | 通用 Bridge API         |
| [@evoker/cli](https://github.com/yizhi996/evoker/tree/main/packages/cli)                     | cli & dev               |
| [@evoker/create-evoker](https://github.com/yizhi996/evoker/tree/main/packages/create-evoker) | template                |
| [@evoker/service](https://github.com/yizhi996/evoker/tree/main/packages/service)             | 逻辑层和 Bridge API     |
| [@evoker/shared](https://github.com/yizhi996/evoker/tree/main/packages/shared)               | 一些公共库                  |
| [test](https://github.com/yizhi996/evoker/tree/main/packages/test)                   | 对 API 进行 e2e 测试      |
| [@evoker/vue](https://github.com/yizhi996/vue-next)                                          | 定制的 Vue              |
| [@evoker/webview](https://github.com/yizhi996/evoker/tree/main/packages/webview)             | WebView 渲染层          |
| [launcher](https://github.com/yizhi996/evoker/tree/main/packages/launcher)           | 应用启动器 |
| [example](https://github.com/yizhi996/evoker/tree/main/packages/example)           | 内置组件和 API 的 example |

## Getting Started

1. Create project with template

- use [hello world](https://github.com/yizhi996/evoker/blob/main/packages/create-evoker/template-blank)
```
pnpm create evoker my-app --template blank --platform iOS
```

2. Install dependencies

```
cd my-app

pnpm install

cd iOS

pod install --repo-update
```

3. Run

```
pnpm dev
```

open iOS/Launcher.xcworkspace

## Licenses

All source code is licensed under the [MIT License](https://github.com/yizhi996/evoker/blob/main/LICENSE).
