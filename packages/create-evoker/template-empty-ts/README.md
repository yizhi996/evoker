# Evoker Empty Template

## 运行 JS

```ts
npm install

npm dev

// or
yarn

yarn dev

// or 
pnpm install

pnpm dev
```

## 运行项目到 iOS 设备

```
cd iOS

pod install
```

打开 `Runner.xcworkspace`，选择设备或者模拟器，点击运行

- 局域网连接需要在 `AppDelegate.swift` 中设置 `DevServer.shared.connect(host: ${host})`