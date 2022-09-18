# Evoker ![platform](https://img.shields.io/badge/platform-iOS%2011-lightgrey?style=flat-square) [![npm](https://img.shields.io/npm/v/evoker?style=flat-square)](https://www.npmjs.com/package/evoker) ![Cocoapods](https://img.shields.io/cocoapods/v/Evoker?color=blue&style=flat-square)

小程序容器（开发中）

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
| [@evoker/shared](https://github.com/yizhi996/evoker/tree/main/packages/shared)               | 公共库                  |
| [@evoker/test](https://github.com/yizhi996/evoker/tree/main/packages/test)                   | e2e 测试                |
| [@evoker/vue](https://github.com/yizhi996/vue-next)                                          | 定制的 Vue              |
| [@evoker/webview](https://github.com/yizhi996/evoker/tree/main/packages/webview)             | WebView 渲染层          |
| [@evoker/launcher](https://github.com/yizhi996/evoker/tree/main/packages/launcher)           | 「wip」全新的应用启动器 |

## Getting Started

1. Create project with template

- use [hello world](https://github.com/yizhi996/evoker/blob/main/packages/create-evoker/template-blank)
```
pnpm create evoker my-app --template blank --platform iOS
```

- use [example](https://github.com/yizhi996/evoker/blob/main/packages/create-evoker/template-example)
```
pnpm create evoker my-app --template example --platform iOS
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

open iOS/Myapp.xcworkspace


## Licenses

All source code is licensed under the [MIT License](https://github.com/yizhi996/evoker/blob/main/LICENSE).
