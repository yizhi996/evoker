//
//  NZEngine.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
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

final public class NZEngine {

    public static let shared = NZEngine()
    
    public var config: NZEngineConfig = NZEngineConfig()
    
    public internal(set) var currentApp: NZAppService?
    
    public internal(set) var runningApp: [NZAppService] = []
    
    public var checkAppUpdateHandler: ((String, NZAppEnvVersion, String, String, NZBoolBlock) -> Void)?
    
    public var getAppInfoHandler: ((String, NZAppEnvVersion, (NZAppInfo) -> Void) -> Void)?
    
    public private(set) var networkType: NetworkType = .unknown {
        didSet {
            NotificationCenter.default.post(name: NZEngine.networkStatusDidChange, object: networkType)
        }
    }
    
    public private(set) lazy var localImageCache = LRUCache<String, String>(maxSize: 1024 * 1024 * 100)
    
    private let processPool = WKProcessPool()
    
    private let networkReachabilityManager = NetworkReachabilityManager()!
    
    private let builtInModules: [NZModule.Type] = [NZVideoModule.self,
                                                   NZAudioModule.self,
                                                   NZInputModule.self,
                                                   NZCameraModule.self,
                                                   NZCanvasModule.self]
    
    public private(set) var extraModules: [NZModule.Type] = []
    
    public private(set) var builtInAPIs: [String: NZAPI] = [:]
    
    public private(set) var extraAPIs: [String: NZAPI] = [:]
    
    private var errorHandler: NZErrorBlock?
    
    var jsContextPool: NZPool<NZJSContext>!
    
    var webViewPool: NZPool<NZWebView>!
    
    private var isLaunch = false
    
    private init() {
        setupBuiltInAPIs()
        setupBuiltInModules()
        setupKTVHTTPCache()
        setupPool()
        setupSDWebImage()
        
        watchNetworkStatus()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDevelopUpdateNotification(_:)),
                                               name: NZDevServer.didUpdateNotification,
                                               object: nil)
    }
    
    public func launch(_ config: NZEngineConfig) {
        if !isLaunch {
            self.config = config
            if config.devServer.useDevServer {
                NZDevServer.shared.connect(host: config.devServer.host, port: config.devServer.port)
            }
            isLaunch = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func preload() {
        preloadJSContext()
        preloadWebView()
    }
    
    func setupBuiltInAPIs() {
        NZRouteAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZRequestAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZUIAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZStorageAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZMediaAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZTongCengAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZNavigateAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZInteractionAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZNavigationAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZPullDownRefreshAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZBatteryAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZVibrateAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZScanAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZScreenAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZCryptoAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
        NZSoundAPI.allCases.forEach { builtInAPIs[$0.rawValue] = $0 }
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
        jsContextPool = NZPool(autoGenerateWithEmpty: false) { [unowned self] in
            return self.createJSContext()
        }
        
        webViewPool = NZPool(autoGenerateWithEmpty: false) { [unowned self] in
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
    
    @objc private func appDevelopUpdateNotification(_ notification: Notification) {
        guard let appId = notification.object as? String, !appId.isEmpty else { return }
        var options = NZAppLaunchOptions()
        options.envVersion = .develop
        let runningId = runningId(appId: appId, envVersion: options.envVersion)
        if let appService = runningApp.first(where: { $0.runningId == runningId }) {
            appService.reLaunch(launchOptions: options)
        } else {
            launchApp(appId: appId, launchOptions: options) { error in
                if let error = error {
                    NZNotifyType.fail(error.localizedDescription).show()
                }
            }
        }
    }
    
    @objc private func didReceiveMemoryWarning() {
        localImageCache.removeAll()
    }
    
    public func onError(_ errorHandler: NZErrorBlock?) {
        self.errorHandler = errorHandler
    }
    
    func runningId(appId: String, envVersion: NZAppEnvVersion) -> String {
        return "\(appId)_\(envVersion)"
    }
}

//MARK: App
extension NZEngine {
    
    public func openApp(appId: String,
                        launchOptions: NZAppLaunchOptions = NZAppLaunchOptions(),
                        presentTo viewController: UIViewController? = nil,
                        completionHandler: ((NZError?) -> Void)? = nil) {
        assert(!appId.isEmpty, "appId cannot be empty")
        let runningId = runningId(appId: appId, envVersion: launchOptions.envVersion)
        if let appService = runningApp.first(where: { $0.runningId == runningId }) {
            guard let rootViewController = appService.rootViewController else {
                completionHandler?(.appRootViewControllerNotFound)
                return
            }
            guard let presentViewController = viewController ?? UIViewController.visibleViewController() else {
                completionHandler?(.presentViewControllerNotFound)
                return
            }
            appService.publishAppOnShow(path: launchOptions.path)
            if !launchOptions.path.isEmpty, let error = appService.reLaunch(url: launchOptions.path) {
                completionHandler?(error)
                return
            }
            presentViewController.present(rootViewController, animated: true)
            completionHandler?(nil)
        } else {
            let updateFinishedHandler: NZBoolBlock = { success in
                self.launchApp(appId: appId, launchOptions: launchOptions) { error in
                    completionHandler?(error)
                }
            }
            if let checkAppUpdateHandler = checkAppUpdateHandler {
                let localVersion = NZVersionManager.shared.localAppVersion(appId: appId,
                                                                           envVersion: launchOptions.envVersion)
                checkAppUpdateHandler(appId,
                                      launchOptions.envVersion,
                                      localVersion,
                                      Constant.version,
                                      updateFinishedHandler)
            } else {
                updateFinishedHandler(true)
            }
        }
    }
    
    public func getAppService(appId: String, envVersion: NZAppEnvVersion) -> NZAppService? {
        assert(!appId.isEmpty, "appId cannot be empty")
        let runningId = runningId(appId: appId, envVersion: envVersion)
        return runningApp.first(where: { $0.runningId == runningId })
    }
    
    public func killAllApp() {
        currentApp = nil
        runningApp.forEach { $0.killApp() }
    }
    
    func launchApp(appId: String,
                   launchOptions: NZAppLaunchOptions,
                   presentTo viewController: UIViewController? = nil,
                   completionHandler handler: @escaping NZErrorBlock) {
        assert(!appId.isEmpty, "appId cannot be empty")
        let getAppInfo: (NZAppInfo) -> Void = { appInfo in
            guard let appService = NZAppService(appId: appId, appInfo: appInfo, launchOptions: launchOptions) else {
                handler(.loadAppConfigFailed)
                return
            }
            if let error = appService.launch(path: launchOptions.path, presentTo: viewController) {
                handler(error)
            } else {
                self.runningApp.append(appService)
                self.currentApp = appService
                handler(nil)
            }
        }
        if let getAppInfoHandler = getAppInfoHandler {
            getAppInfoHandler(appId, launchOptions.envVersion, getAppInfo)
        } else {
            getAppInfo(NZAppInfo(appName: appId, appIconURL: ""))
        }
    }

}

extension NZEngine {
    
    public func injectModule(_ module: NZModule.Type) {
        guard !extraModules.contains(where: { $0.name == module.name }) else { return }
        extraModules.append(module)
        module.apis.forEach { extraAPIs[$0.key] = $0.value }
    }
    
    func allModules() -> [NZModule.Type] {
        return builtInModules + extraModules
    }
    
    public func registAPI(_ name: String, api: NZAPI) {
        extraAPIs[name] = api
    }
    
}

//MARK: WebView
public extension NZEngine {
        
    func createWebView() -> NZWebView {
        let config = WKWebViewConfiguration()
        config.processPool = processPool
        
        let webPHandler = NZWebPSchemeHandler()
        config.setURLSchemeHandler(webPHandler, forURLScheme: "webphttp")
        config.setURLSchemeHandler(webPHandler, forURLScheme: "webphttps")
        
        let rect = CGRect(x: -Constant.windowWidth, y: 0, width: Constant.windowWidth, height: Constant.windowHeight)
        let webView = NZWebView(frame: rect, configuration: config)
        let version = NZVersionManager.shared.localJSSDKVersion
        let jsSDKDir = FilePath.jsSDK(version: version)
        let indexHTMLFileURL = jsSDKDir.appendingPathComponent("index.html")
        webView.loadFileURL(indexHTMLFileURL, allowingReadAccessTo: FilePath.documentDirectory())
        UIApplication.shared.keyWindow!.addSubview(webView)
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
public extension NZEngine {

    func createJSContext() -> NZJSContext {
        let context = NZJSContext()
        return context
    }
    
    func preloadJSContext() {
        if jsContextPool.count == 0 {
            let context = createJSContext()
            jsContextPool.push(context)
        }
    }
}

extension NZEngine {
    
    func reportError(_ error: NZError) {
        errorHandler?(error)
    }
    
    func reportLog(_ log: String) {
        print(log)
    }
}

public extension NZEngine {
    
    static let networkStatusDidChange = Notification.Name("NZothNetworkStatusDidChange")
}

public struct NZAppInfo {
    
    public var appName: String = ""
    
    public var appIconURL: String = ""
    
    public init() {
        
    }
    
    public init(appName: String, appIconURL: String) {
        self.appName = appName
        self.appIconURL = appIconURL
    }
}

public struct NZAppLaunchOptions {
    
    public struct ReferrerInfo {
        let appId: String
        
        let extraDataString: String?
    }
        
    public var path: String = ""
    
    public var scene: Int = 0
    
    public var query: String = ""
    
    public var referrerInfo: ReferrerInfo?
    
    public var envVersion: NZAppEnvVersion = .release
    
    public var custom: [String: Any] = [:]
    
    public init() {
        
    }
}
