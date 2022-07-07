# Evoker ![platform](https://img.shields.io/badge/platform-iOS%2011-lightgrey?style=flat-square) [![npm](https://img.shields.io/npm/v/evoker?style=flat-square)](https://www.npmjs.com/package/evoker) ![Cocoapods](https://img.shields.io/cocoapods/v/Evoker?color=blue&style=flat-square)

小程序容器（开发中）

## Documentation

[evokerdev.com](https://evokerdev.com)

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
