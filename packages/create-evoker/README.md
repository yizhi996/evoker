# create-evoker

快速创建 Evoker 应用脚手架。

### 创建空白脚手架

```
// use npm 
npm create evoker my-app --template blank --platform iOS

// use yarn
yarn create evoker my-app --template blank --platform iOS

// use pnpm
pnpm create evoker my-app --template blank --platform iOS
```

### 其他模板 `--template`

* example 包含所有内置组件和大部分 API 的示例

### 启动应用

1. 启动 Node 项目
```
cd my-app

// 安装依赖
npm / yarn /pnpm install

// 启动 dev server
npm / yarn /pnpm run dev
```

2. 启动 iOS
```
cd my-app/iOS

// 安装 iOS 依赖
pod install
```

3. 打开 `iOS/${projectName}.xcworkspace` 运行在指定设备或者模拟器

* 如果要在真机运行，请设置 Bundle Identifier 和 签名证书