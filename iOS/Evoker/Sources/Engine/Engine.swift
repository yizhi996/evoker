//
//  Engine.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import WebKit
import KTVHTTPCache
import Alamofire
import SDWebImage
import SDWebImageWebPCoder
import MediaPlayer

final public class Engine {

    public static let shared = Engine()
    
    public let config = EngineConfig()
    
    /// 数据存储在   userId → [appId_a]   [appId_b]  [...] 中，
    /// 具有 user Id 和 app Id 两级隔离。
    public var userId = "__global__"
    
    public internal(set) var currentApp: AppService?
    
    public internal(set) var runningApp: [AppService] = []
    
    public private(set) var networkType: NetworkType = .unknown {
        didSet {
            NotificationCenter.default.post(name: Engine.networkStatusDidChange, object: networkType)
        }
    }
    
    private let processPool = WKProcessPool()
    
    private let networkReachabilityManager = NetworkReachabilityManager()!
    
    private let builtInModules: [Module.Type] = [
        VideoModule.self,
        AudioModule.self,
        InputModule.self,
        CameraModule.self,
        CanvasModule.self,
        LocationModule.self,
        AudioRecorderModule.self,
        WebSocketModule.self
    ]
    
    public private(set) var extraModules: [Module.Type] = []
    
    public private(set) var builtInAPIs: [String: API] = [:]
    
    public private(set) var extraAPIs: [String: API] = [:]
    
    private var errorHandler: EKErrorBlock?
    
    lazy var volumeSlider: UISlider = {
        let volumeView = MPVolumeView()
        return volumeView.subviews.first(ofType: UISlider.self)!
    }()
    
    var jsContextPool: Pool<JSContext>!
    
    var webViewPool: Pool<WebView>!
    
    var userAgent = ""
    
    var shouldInteractivePopGesture = true
    
    private var devServer: DevServer?
    
    private var isLaunch = false
    
    private init() {
        try? PackageManager.shared.unpackBudleSDK()
        
        setupBuiltInAPIs()
        setupBuiltInModules()
        setupKTVHTTPCache()
        setupPool()
        setupSDWebImage()
        
        watchNetworkStatus()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDevelopUpdateNotification(_:)),
                                               name: DevServer.didUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func preload() {
        preloadJSContext()
        preloadWebView()
    }
    
    func setupBuiltInAPIs() {
        RouteAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        RequestAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        ScrollAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        StorageAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        MediaAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        TongCengAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NavigateAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        InteractionAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NavigationAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        PullDownRefreshAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        BatteryAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        VibrateAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        ScanAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        ScreenAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        CryptoAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        SoundAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        ClipboardAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        PhoneAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NetworkAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        LifeCycleAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        AuthAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        OpenAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        TabBarAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        VolumeAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        PickerAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        ShareAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        FileAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
    }
    
    func setupBuiltInModules() {
        builtInModules.forEach { module in
            module.apis.forEach { builtInAPIs[$0.key] = $0.value }
        }
    }
    
    func setupKTVHTTPCache() {
        KTVHTTPCache.logSetRecordLogEnable(false)
        KTVHTTPCache.cacheSetMaxCacheLength(1024 * 1024 * 1024)
    }
    
    func setupPool() {
        jsContextPool = Pool(autoGenerateWithEmpty: false) { [unowned self] in
            return self.createJSContext()
        }
        
        webViewPool = Pool(autoGenerateWithEmpty: false) { [unowned self] in
            return self.createWebView()
        }
    }
    
    func setupSDWebImage() {
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        SDWebImageDownloader.shared.setValue("image/webp,image/png,image/*;q=0.8,*/*;q=0.5",
                                             forHTTPHeaderField: "Accept")
    }
    
    func watchNetworkStatus() {
        networkReachabilityManager.startListening(onUpdatePerforming: { [unowned self] status in
            switch status {
            case .unknown:
                self.networkType = .unknown
            case .notReachable:
                self.networkType = .none
            case .reachable(let type):
                switch type {
                case .ethernetOrWiFi:
                    self.networkType = .wifi
                case .cellular:
                    self.networkType = Network.getCellularType()
                }
            }
        })
    }
    
    @objc
    private func appDevelopUpdateNotification(_ notification: Notification) {
        guard let info = notification.object as? [String: Any],
              let appId = info["appId"] as? String,
              !appId.isEmpty else { return }
        var options = AppLaunchOptions()
        options.envVersion = .develop
        if let launchOptions = info["launchOptions"] as? DevServer.AppUpdateOptions.LaunchOptions {
            options.path = launchOptions.page
        }
        if let appService = runningApp.first(where: { $0.appId == appId && $0.envVersion == .develop }) {
            appService.reLaunch(launchOptions: options)
        } else {
            launchApp(appId: appId, launchOptions: options) { error in
                if let error = error {
                    NotifyType.fail(error.localizedDescription).show()
                }
            }
        }
    }
    
    @objc private func willEnterForeground() {
        guard let currentApp = currentApp else { return }
        currentApp.publishAppOnShow(options: AppShowOptions())
        if let webPage = currentApp.currentPage as? WebPage {
            if webPage.webView.state == .terminate {
                webPage.reload()
            } else {
                webPage.publishOnShow()
            }
        }
    }
    
    @objc private func didEnterBackground() {
        guard let currentApp = currentApp else { return }
        currentApp.publishAppOnHide()
        if let webPage = currentApp.currentPage as? WebPage {
            webPage.publishOnHide()
        }
    }
    
    @objc private func willTerminate() {
        FilePath.cleanTemp()
    }
    
    public func onError(_ errorHandler: EKErrorBlock?) {
        self.errorHandler = errorHandler
    }

}

//MARK: App
extension Engine {
    
    /// 打开应用
    /// - Parameters:
    ///     - appId: 应用唯一标识
    ///     - launchOptions: 应用启动参数
    ///     - presentTo: 打开在目标 ViewController
    ///     - completionHandler: 打开完成时调用
    public func openApp(appId: String,
                        launchOptions: AppLaunchOptions = AppLaunchOptions(),
                        presentTo viewController: UIViewController? = nil,
                        completionHandler: ((EKError?) -> Void)? = nil) {
        assert(!appId.isEmpty, "appId cannot be empty")
        
        if let appService = runningApp.first(where: { $0.appId == appId && $0.envVersion == launchOptions.envVersion }) {
            guard let rootViewController = appService.rootViewController else {
                completionHandler?(.appRootViewControllerNotFound)
                return
            }
            
            guard let presentViewController = viewController ?? UIViewController.visibleViewController() else {
                completionHandler?(.presentViewControllerNotFound)
                return
            }
            
            var showOptions = AppShowOptions()
            showOptions.path = launchOptions.path
            showOptions.referrerInfo = launchOptions.referrerInfo
            appService.publishAppOnShow(options: showOptions)
            if let webPage = appService.currentPage as? WebPage {
                if webPage.webView.state == .terminate {
                    webPage.reload()
                } else {
                    webPage.publishOnShow()
                }
            }
            if !launchOptions.path.isEmpty, let error = appService.reLaunch(url: launchOptions.path) {
                completionHandler?(error)
                return
            }
            presentViewController.present(rootViewController, animated: true)
            completionHandler?(nil)
        } else {
            let updateFinishedHandler: BoolBlock = { success in
                self.launchApp(appId: appId, launchOptions: launchOptions) { error in
                    completionHandler?(error)
                }
            }
            
            if let checkAppUpdateHandler = Engine.shared.config.hooks.app.checkAppUpdate {
                let localVersion = PackageManager.shared.localAppVersion(appId: appId,
                                                                           envVersion: launchOptions.envVersion)
                checkAppUpdateHandler(appId,
                                      launchOptions.envVersion,
                                      localVersion,
                                      Constant.nativeSDKVersion,
                                      updateFinishedHandler)
            } else {
                updateFinishedHandler(true)
            }
        }
    }
    
    public func getAppService(appId: String, envVersion: AppEnvVersion) -> AppService? {
        assert(!appId.isEmpty, "appId cannot be empty")
        return runningApp.first(where: { $0.appId == appId && $0.envVersion == envVersion })
    }
    
    public func exitAllApp() {
        currentApp = nil
        runningApp.forEach { $0.exit() }
    }
    
    public struct ClearOptions: OptionSet {
        public static let data = ClearOptions(rawValue: 1 << 0)
        
        public static let file = ClearOptions(rawValue: 1 << 1)
        
        public static let authorization = ClearOptions(rawValue: 1 << 2)
        
        public static let compile = ClearOptions(rawValue: 1 << 3)
        
        public static let all: ClearOptions = [.data, .file, .authorization, .compile]

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public func clearAppData(appId: String, userId: String, options: ClearOptions) {
        lazy var storage = AppStorage(appId: appId)
        if options.contains(.data) {
            if let error = storage.clear() {
                Logger.error("clear app data of data \(error.localizedDescription)")
            }
        }
        if options.contains(.file) {
            let storeDir = FilePath.store(appId: appId, userId: userId)
            let usrDir = FilePath.usr(appId: appId, userId: userId)
            do {
                try FileManager.default.removeItem(at: storeDir)
                try FileManager.default.removeItem(at: usrDir)
            } catch {
                Logger.error("clear app data of file \(error.localizedDescription)")
            }
        }
        if options.contains(.authorization) {
            if let error = storage.clearAuthorization() {
                Logger.error("clear app data of authorization \(error.localizedDescription)")
            }
        }
        if options.contains(.compile) {
            let dir = FilePath.app(appId: appId)
            do {
                try FileManager.default.removeItem(at: dir)
            } catch {
                Logger.error("clear app compile data fail \(error.localizedDescription)")
            }
        }
    }
    
    func launchApp(appId: String,
                   launchOptions: AppLaunchOptions,
                   presentTo viewController: UIViewController? = nil,
                   completionHandler handler: @escaping EKErrorBlock) {
        assert(!appId.isEmpty, "appId cannot be empty")
        getAppInfo(appId: appId, envVersion: launchOptions.envVersion) { appInfo, error in
            if let error = error {
                handler(error)
                return
            }
            guard let appService = AppService(appId: appId, appInfo: appInfo!, launchOptions: launchOptions) else {
                handler(.loadAppConfigFailed)
                return
            }
            if let error = appService.launch(to: viewController) {
                handler(error)
            } else {
                self.runningApp.append(appService)
                self.currentApp = appService
                handler(nil)
            }
        }
    }
    
    public func getAppInfo(appId: String, envVersion: AppEnvVersion, completionHandler: (AppInfo?, EKError?) -> Void) {
        if let getAppInfoHandler = Engine.shared.config.hooks.app.getAppInfo {
            getAppInfoHandler(appId, envVersion, completionHandler)
        } else {
            completionHandler(AppInfo(appName: appId, appIconURL: ""), nil)
        }
    }
}

extension Engine {
    
    /// 注入 Module
    public func injectModule(_ module: Module.Type) {
        guard !extraModules.contains(where: { $0.name == module.name }) else { return }
        extraModules.append(module)
        module.apis.forEach { extraAPIs[$0.key] = $0.value }
    }
    
    func allModules() -> [Module.Type] {
        return builtInModules + extraModules
    }
    
    /// 注册 API，根据 name 可以覆盖内置 API 或者 注册新的 API
    public func registAPI(_ name: String, api: API) {
        extraAPIs[name] = api
    }
    
}

//MARK: WebView
public extension Engine {
        
    func createWebView() -> WebView {
        let config = WKWebViewConfiguration()
        config.processPool = processPool
        
        let webPHandler = WebPSchemeHandler()
        config.setURLSchemeHandler(webPHandler, forURLScheme: "webphttp")
        config.setURLSchemeHandler(webPHandler, forURLScheme: "webphttps")
        
        let navigationBarHeight = Constant.topHeight
        let rect = CGRect(x:  -Constant.windowWidth,
                          y: navigationBarHeight,
                          width: Constant.windowWidth,
                          height: Constant.windowHeight - navigationBarHeight)
        let webView = WebView(frame: rect, configuration: config)
        let version = PackageManager.shared.localJSSDKVersion
        let jsSDKDir = FilePath.jsSDK(version: version)
        let indexHTMLFileURL = jsSDKDir.appendingPathComponent("index.html")
        webView.loadFileURL(indexHTMLFileURL, allowingReadAccessTo: FilePath.documentDirectory())
        UIApplication.shared.keyWindow!.addSubview(webView)
        webView.removeFromSuperview()
        return webView
    }
    
    func preloadWebView() {
        if webViewPool.count == 0 {
            let webView = createWebView()
            webViewPool.push(webView)
        }
    }
}

//MARK: JSContext
public extension Engine {

    func createJSContext() -> JSContext {
        let context = JSContext()
        return context
    }
    
    func preloadJSContext() {
        if jsContextPool.count == 0 {
            let context = createJSContext()
            jsContextPool.push(context)
        }
    }
}

extension Engine {
    
    func reportError(_ error: EKError) {
        errorHandler?(error)
    }
    
    func reportLog(_ log: String) {
        print(log)
    }
}

extension Engine {
    
    public func connectDevService(host: String = "", port: UInt16 = 5173) {
        devServer = DevServer(host: host, port: port)
        devServer!.connect()
    }
}

public extension Engine {
    
    static let networkStatusDidChange = Notification.Name("EvokerNetworkStatusDidChange")
}
