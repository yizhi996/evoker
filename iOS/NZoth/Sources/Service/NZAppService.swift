//
//  NZAppService.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import JavaScriptCore
import WebKit
import Alamofire

final public class NZAppService {
    
    public enum State: Int {
        case front = 0
        case back
        case suspend
    }
    
    public let config: NZAppConfig
    
    public private(set) var appInfo: NZAppInfo
               
    public let launchOptions: NZAppLaunchOptions
    
    public var appId: String {
        return config.appId
    }
    
    public var envVersion: NZAppEnvVersion {
        return launchOptions.envVersion
    }
    
    public var haveTabBar: Bool {
        return config.tabBar?.list.isEmpty == false
    }

    public internal(set) var state: State = .back
    
    public internal(set) var currentPage: NZPage?
    
    public internal(set) var pages: [NZPage] = []
    
    public private(set) var bridge: NZJSBridge!
    
    public let uiControl = NZAppUIControl()
    
    public lazy var storage: NZAppStorage = {
        return NZAppStorage(appId: appId)
    }()
    
    public internal(set) var rootViewController: NZNavigationController? {
        didSet {
            if let rootViewController = rootViewController {
                rootViewController.themeChangeHandler = { [unowned self] theme in
                    self.bridge.subscribeHandler(method: Self.themeChangeSubscribeKey, data: ["theme": theme])
                }
                uiControl.addCapsuleView(to: rootViewController.view)
            }
        }
    }
    
    public lazy var tabBarPages: [NZPage] = []
    
    public lazy var requests: [Int: Request] = [:]
    
    public internal(set) var modules: [String: NZModule] = [:]
    
    private var incPageId = 0
    
    private var killTimer: Timer?
    
    lazy var context: NZJSContext = {
        return NZEngine.shared.jsContextPool.idle()
    }()
    
    var runningId: String {
        return "\(appId)_\(envVersion)"
    }
    
    var webViewPool: NZPool<NZWebView>!
    
    init?(appId: String, appInfo: NZAppInfo, launchOptions: NZAppLaunchOptions) {
        guard !appId.isEmpty,
              let config = NZAppConfig.load(appId: appId, envVersion: launchOptions.envVersion),
              !config.pages.isEmpty else { return nil }
        self.appInfo = appInfo
        if appInfo.appName.isEmpty {
            self.appInfo.appName = appId
        }
        self.launchOptions = launchOptions
        self.config = config
        
        context.name = "\(self.appInfo.appName) - app-service"
        context.nativeSDK.appId = appId
        context.nativeSDK.envVersion = launchOptions.envVersion
        
        bridge = NZJSBridge(appService: self, container: context)

        setupModules()
        
        webViewPool = NZPool(autoGenerateWithEmpty: true) { [unowned self] in
            return self.createWebView()
        }
        
        uiControl.closeHandler = { [unowned self] in
            self.closeMiniProgram()
        }
        
        uiControl.didSelectTabBarIndexHandler = { [unowned self] index in
            let page = self.tabBarPages[index]
            if !pages.contains(where: { $0.pageId == page.pageId }) {
                pages.append(page)
            }
            let viewController = page.viewController ?? page.generateViewController()
            uiControl.tabBarViewControllers[page.url] = viewController
            if !viewController.isViewLoaded {
                viewController.loadViewIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.rootViewController?.viewControllers = [viewController]
                    if page.isShowTabBar {
                        self.uiControl.addTabBar(to: viewController.view)
                        self.uiControl.tabBarView.setTabItemSelect(index)
                    }
                }
            } else {
                self.rootViewController?.viewControllers = [viewController]
                if page.isShowTabBar {
                    self.uiControl.addTabBar(to: viewController.view)
                    self.uiControl.tabBarView.setTabItemSelect(index)
                }
            }
        }
        
        uiControl.showAppMoreActionBoardHandler = { [unowned self] in
            guard let rootViewController = self.rootViewController else { return }
            self.uiControl.showAppMoreActionBoard(appId: self.appId,
                                                  appInfo: self.appInfo,
                                                  to: rootViewController.view) { [unowned self] action in
                self.invokeAppMoreAction(action)
            }
        }

        context.invokeHandler = { [unowned self] message in
            guard let event = message["event"] as? String,
                  let params = message["params"] as? String,
                  let callbackId = message["callbackId"] as? Int else { return }
            let args = NZJSBridge.InvokeArgs(eventName: event,
                                    paramsString: params,
                                    callbackId: callbackId)
            self.bridge.onInvoke(args)
        }
        
        context.publishHandler = { [unowned self] message in
            guard let event = message["event"] as? String,
                  let webViewId = message["webViewId"] as? Int,
                  let params = message["params"] as? String,
                  let page = self.findWebPage(from: webViewId) else { return }
            page.webView.bridge.subscribeHandler(method: NZSubscribeKey(event),
                                                data: params,
                                                webViewId: webViewId)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusDidChange(_:)),
                                               name: NZEngine.networkStatusDidChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidTakeScreenshot),
                                               name: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil)
    }
    
    deinit {
        NZLogger.debug("\(appId) app service deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupModules() {
        NZEngine.shared.allModules().forEach { modules[$0.name] = $0.init(appService: self) }
    }
    
    func launch(path: String, presentTo viewController: UIViewController? = nil) -> NZError? {
        guard let info = generateFirstViewController(with: path) else { return .appLaunchPathNotFound(path) }
        if haveTabBar {
            uiControl.setupTabBar(config: config, envVersion: envVersion)
            uiControl.tabBarView.setTabItemSelect(info.tabBarSelectedIndex)
            uiControl.tabBarViewControllers = [:]
            if info.page.isTabBarPage {
                uiControl.tabBarViewControllers[info.page.url] = info.viewController
            }
            tabBarPages = info.tabBarPages
        }
        pages.append(info.page)
        loadAppPackage()
        publishAppOnLaunch(path: path)
        
        let navigationController = NZNavigationController(rootViewController: info.viewController)
        navigationController.modalPresentationStyle = .fullScreen
        if info.needAddGotoHomeButton {
            info.viewController.navigationBar.showGotoHomeButton()
        }
        rootViewController = navigationController
        let presentViewController = viewController ?? UIViewController.visibleViewController()
        presentViewController?.present(navigationController, animated: true)
        if info.page.isTabBarPage {
            uiControl.addTabBar(to: info.viewController.view)
        }
        state = .front
        publishAppOnShow(path: path)
        return nil
    }
    
    func loadAppPackage() {
        let dist = FilePath.appDist(appId: appId, envVersion: launchOptions.envVersion)
        let appServiceURL = dist.appendingPathComponent("app-service.js")
        if let js = try? String(contentsOfFile: appServiceURL.path) {
            context.evaluateScript(js, name: "app-service.js")
            var cfgjs = """
            globalThis.__NZConfig.appName = '\(appInfo.appName)';
            globalThis.__NZConfig.appIcon = '\(appInfo.appIconURL)';
            """
            if let userInfo = appInfo.userInfo.toJSONString() {
                cfgjs += "globalThis.__NZConfig.userInfo = \(userInfo);"
            } else {
                cfgjs += "globalThis.__NZConfig.userInfo = {};"
            }
            context.evaluateScript(cfgjs)
        } else {
            NZLogger.error("load app code failed: \(appServiceURL.path) file not exist")
        }
    }
    
    func genPageId() -> Int {
        incPageId += 1
        return incPageId
    }
    
    public func findWebPage(from pageId: Int) -> NZWebPage? {
        return pages.first(where: { $0.pageId == pageId }) as? NZWebPage
    }
    
    public func getModule<T: NZModule>() -> T? {
        return modules[T.name] as? T
    }
    
    public func reLaunch(launchOptions: NZAppLaunchOptions? = nil) {
        dismiss(animated: false) {
            self.killApp()
            if NZEngine.shared.config.devServer.useDevServer {
                NZEngine.shared.webViewPool.clean()
            }
            let launchOptions = launchOptions ?? self.launchOptions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                NZEngine.shared.launchApp(appId: self.appId, launchOptions: launchOptions) { error in
                    if let error = error {
                        NZLogger.error(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func exit(animated: Bool = true) {
        dismiss(animated: animated) { [unowned self] in
            self.killApp()
        }
    }
    
    @objc
    private func killApp() {
        cleanKillTimer()
        context.clearAllTimer()
        unloadAllPages()
        rootViewController = nil
        if haveTabBar {
            tabBarPages = []
            uiControl.tabBarViewControllers = [:]
        }
        currentPage = nil
        modules.values.forEach { $0.onExit(self) }
        modules = [:]
        
        if let index = NZEngine.shared.runningApp.firstIndex(of: self) {
            NZEngine.shared.runningApp.remove(at: index)
        }
        if NZEngine.shared.currentApp === self {
            NZEngine.shared.currentApp = nil
        }
    }
    
    func unloadPage(_ page: NZPage) {
        modules.values.forEach { $0.onUnload(page) }
        if let webPage = page as? NZWebPage {
            webPage.unload()
        }
        if let index = pages.firstIndex(where: { $0.pageId == page.pageId }) {
            pages.remove(at: index)
        }
    }
    
    func unloadAllPages() {
        pages.forEach { unloadPage($0) }
        pages = []
    }
    
    func cleanKillTimer() {
        killTimer?.invalidate()
        killTimer = nil
    }
    
    @objc
    func networkStatusDidChange(_ notification: Notification) {
        guard let netType = notification.object as? NetworkType else { return }
        bridge.subscribeHandler(method: NZSubscribeKey("APP_NETWORK_STATUS_CHANGE"), data: [
            "isConnected": netType != .none,
            "networkType": netType.rawValue
        ])
    }
    
    @objc
    func userDidTakeScreenshot() {
        bridge.subscribeHandler(method: NZSubscribeKey("APP_USER_CAPTURE_SCREEN"), data: [:])
    }
}

extension NZAppService {
    
    struct GenerateFirstViewControllerInfo {
        let page: NZPage
        let viewController: NZPageViewController
        let tabBarSelectedIndex: Int
        let needAddGotoHomeButton: Bool
        let tabBarPages: [NZPage]
    }
    
    func generateFirstViewController(with path: String) -> GenerateFirstViewControllerInfo? {
        var route = path
        var query = ""
        if let queryIndex = path.firstIndex(of: "?") {
            route = String(path[path.startIndex..<queryIndex])
            query = String(path[queryIndex..<path.endIndex])
        }
        
        var tabBarPages: [NZWebPage] = []
        if let tabBarInfo = config.tabBar, !tabBarInfo.list.isEmpty {
            let tabBarItems = tabBarInfo.list.filter { tab in
                return config.pages.contains { $0.path == tab.path }
            }
            
            for (i, item) in tabBarItems.enumerated() {
                var pagePath: String
                if !path.isEmpty {
                    if route.isEmpty && i == 0 {
                        pagePath = item.path + query
                    } else if route == item.path {
                        pagePath = path
                    } else {
                        pagePath = item.path
                    }
                } else {
                    pagePath = item.path
                }
                
                if let page = createWebPage(url: pagePath) {
                    page.isTabBarPage = true
                    tabBarPages.append(page)
                }
            }
        }
        
        var firstTabBarPage: NZPage?
        var tabBarSelectedIndex = 0
        
        for (i, page) in tabBarPages.enumerated() {
            if !path.isEmpty && page.url == path {
                firstTabBarPage = page
                tabBarSelectedIndex = i
            }
        }
        
        // 打开指定 tab
        if let firstTabBarPage = firstTabBarPage {
            return GenerateFirstViewControllerInfo(page: firstTabBarPage,
                                                   viewController: firstTabBarPage.generateViewController(),
                                                   tabBarSelectedIndex: tabBarSelectedIndex,
                                                   needAddGotoHomeButton: false,
                                                   tabBarPages: tabBarPages)
        }
        
        // 打开首个 tab
        if route.isEmpty && !tabBarPages.isEmpty {
            let page = tabBarPages[0]
            return GenerateFirstViewControllerInfo(page: page,
                                                   viewController: page.generateViewController(),
                                                   tabBarSelectedIndex: 0,
                                                   needAddGotoHomeButton: false,
                                                   tabBarPages: tabBarPages)
        }
        
        // 打开指定 page
        if config.pages.contains(where: { $0.path == route }), let page = createWebPage(url: path) {
            return GenerateFirstViewControllerInfo(page: page,
                                                   viewController: page.generateViewController(),
                                                   tabBarSelectedIndex: 0,
                                                   needAddGotoHomeButton: checkAddGotoHomeButton(path: path),
                                                   tabBarPages: tabBarPages)
        } else if let first = config.pages.first { // 打开首页
            if let page = createWebPage(url: first.path + query) {
                return GenerateFirstViewControllerInfo(page: page,
                                                       viewController: page.generateViewController(),
                                                       tabBarSelectedIndex: 0,
                                                       needAddGotoHomeButton: false,
                                                       tabBarPages: tabBarPages)
            }
        }
        return nil
    }
}

//MARK: View
extension NZAppService {
    
    func checkAddGotoHomeButton(path: String) -> Bool {
        let (route, _) = path.decodeURL()
        if let tabBarList = config.tabBar?.list, !tabBarList.isEmpty {
            return !tabBarList.contains(where: { $0.path == route })
        }
        return config.pages.first?.path != route
    }
    
    func gotoHomePage() {
        if let firstTabBar = config.tabBar?.list.first, let info = generateFirstViewController(with: firstTabBar.path) {
            unloadAllPages()
            uiControl.setupTabBar(config: config, envVersion: envVersion)
            uiControl.tabBarView.setTabItemSelect(info.tabBarSelectedIndex)
            uiControl.tabBarViewControllers = [:]
            uiControl.tabBarViewControllers[info.page.url] = info.viewController
            tabBarPages = info.tabBarPages
            pages.append(info.page)
            rootViewController?.viewControllers = [info.viewController]
            uiControl.addTabBar(to: info.viewController.view)
        } else if let firstPage = config.pages.first,
                  let page = createWebPage(url: firstPage.path) {
            unloadAllPages()
            pages.append(page)
            let viewController = page.generateViewController()
            rootViewController?.viewControllers = [viewController]
        }
    }

    func closeMiniProgram() {
        dismiss()
        cleanKillTimer()
        state = .suspend
        
        killTimer = Timer(timeInterval: 15 * 60,
                          target: self,
                          selector: #selector(killApp),
                          userInfo: nil,
                          repeats: false)
        RunLoop.main.add(killTimer!, forMode: .common)
    }
    
    func invokeAppMoreAction(_ action: String) {
        switch action {
        case "settings":
            let viewModel = NZSettingViewModel(appService: self)
            rootViewController?.pushViewController(viewModel.generateViewController(), animated: true)
            break
        case "relaunch":
            var options = NZAppLaunchOptions()
            options.envVersion = envVersion
            reLaunch(launchOptions: options)
        default:
            break
        }
    }
}

//MARK: WebView
extension NZAppService {
    
    func createWebView() -> NZWebView {
        let webView = NZEngine.shared.createWebView()
        loadAppCSS(to: webView)
        return webView
    }
    
    func preloadWebView() {
        let webView = createWebView()
        webViewPool.push(webView)
    }
    
    func loadAppCSS(to webView: NZWebView) {
        webView.runAfterLoad { [weak self] in
            guard let self = self else { return }
            let cssURL = FilePath.appDist(appId: self.appId, envVersion: self.envVersion)
                .appendingPathComponent("style.css").absoluteString
            let loadAppCSS =
            """
            const link = document.createElement("link");
            link.rel="stylesheet";
            link.type="text/css";
            link.href="\(cssURL)"
            document.head.appendChild(link)
            """
            webView.evaluateJavaScript(loadAppCSS) { _, error in
                if let error = error as? WKError, error.code != .javaScriptResultTypeIsUnsupported {
                    NZLogger.error("WebView eval \(loadAppCSS) failed: \(error)")
                }
            }
        }
    }
    
    func recycle(webView: NZWebView) {
        webViewPool.clean { webView in
            webView.removeFromSuperview()
        }
        webView.recycle()
        loadAppCSS(to: webView)
        webViewPool.push(webView)
    }
    
    public func idleWebView() -> NZWebView {
        let webView =  webViewPool.idle()
        webView.removeFromSuperview()
        return webView
    }
}

//MARK: App Life cycle publish
extension NZAppService {
    
    func publishAppOnLaunch(path: String) {
        let message: [String: Any] = ["path": path]
        bridge.subscribeHandler(method: NZAppService.onLaunchSubscribeKey, data: message)
        modules.values.forEach { $0.onLaunch(self) }
    }
    
    func publishAppOnShow(path: String) {
        cleanKillTimer()
        let message: [String: Any] = ["path": path]
        bridge.subscribeHandler(method: NZAppService.onShowSubscribeKey, data: message)
        modules.values.forEach { $0.onShow(self) }
    }
    
    @objc func publishAppOnHide() {
        let message: [String: Any] = [:]
        bridge.subscribeHandler(method: NZAppService.onHideSubscribeKey, data: message)
        modules.values.forEach { $0.onHide(self) }
    }
}

extension NZAppService {
    
    func createWebPage(url: String) -> NZWebPage? {
        return NZEngine.shared.config.webPageClass.init(appService: self, url: url)
    }
    
    func createBrowserPage(url: String) -> NZBrowserPage? {
        return NZEngine.shared.config.browserPageClass.init(appService: self, url: url)
    }
}

public extension NZAppService {
    
    func push(_ page: NZPage, animated: Bool = true, completedHandler: NZEmptyBlock? = nil) {
        pages.append(page)
        let viewController = page.generateViewController()
        viewController.loadCompletedHandler = {
            completedHandler?()
        }
        viewController.loadViewIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.rootViewController?.pushViewController(viewController, animated: true)
        }
    }
    
    func redirectTo(_ url: String) -> NZError? {
        guard config.tabBar?.list.contains(where: { $0.path == url }) == false else {
            return .bridgeFailed(reason: .cannotToTabbarPage)
        }
        guard let rootViewController = rootViewController else {
            return .appRootViewControllerNotFound
        }
        guard let info = generateFirstViewController(with: url) else {
            return .appLaunchPathNotFound(url)
        }
        if let currentPage = currentPage {
            if currentPage.isTabBarPage {
                unloadAllPages()
                uiControl.tabBarViewControllers = [:]
                pages.append(info.page)
                rootViewController.viewControllers = [info.viewController]
                if info.needAddGotoHomeButton {
                    info.viewController.navigationBar.showGotoHomeButton()
                }
            } else {
                unloadPage(currentPage)
                pages.append(info.page)
                rootViewController.viewControllers.removeLast()
                rootViewController.viewControllers.append(info.viewController)
                if pages.count == 1 {
                    info.viewController.navigationBar.showGotoHomeButton()
                }
            }
        }
        return nil
    }
    
    func pop(delta: Int = 1, animated: Bool = true) {
        guard let rootViewController = rootViewController else { return }
        if delta <= 1 {
            rootViewController.popViewController(animated: true)
        } else if rootViewController.viewControllers.count >= delta {
            let viewController = rootViewController.viewControllers.reversed()[delta]
            rootViewController.popToViewController(viewController, animated: animated)
        } else {
            rootViewController.popToRootViewController(animated: animated)
        }
    }
    
    func dismiss(animated: Bool = true, completion: NZEmptyBlock? = nil) {
        publishAppOnHide()
        rootViewController?.dismiss(animated: animated, completion: completion)
    }
    
    func reLaunch(url: String) -> NZError? {
        guard let rootViewController = rootViewController else { return .appRootViewControllerNotFound }
        guard let info = generateFirstViewController(with: url) else { return .appLaunchPathNotFound(url) }
        
        currentPage = nil
        unloadAllPages()
        
        if haveTabBar {
            uiControl.setupTabBar(config: config, envVersion: envVersion)
            uiControl.tabBarView.setTabItemSelect(info.tabBarSelectedIndex)
            uiControl.tabBarViewControllers = [:]
            if info.page.isTabBarPage {
                uiControl.tabBarViewControllers[info.page.url] = info.viewController
                
            }
            tabBarPages = info.tabBarPages
        }
        pages.append(info.page)
        
        rootViewController.viewControllers = [info.viewController]
        if info.page.isTabBarPage {
            uiControl.addTabBar(to: info.viewController.view)
        }
        if info.needAddGotoHomeButton {
            info.viewController.navigationBar.showGotoHomeButton()
        }
        return nil
    }
    
    func switchTo(url: String) {
        if let index = tabBarPages.filter(ofType: NZWebPage.self).firstIndex(where: { $0.url == url }) {
            uiControl.didSelectTabBarIndexHandler?(index)
        }
    }
}

//MARK: NZSubscribeKey
extension NZAppService {
    
    public static let onLaunchSubscribeKey = NZSubscribeKey("APP_ON_LAUNCH")
    
    public static let onShowSubscribeKey = NZSubscribeKey("APP_ON_SHOW")
    
    public static let onHideSubscribeKey = NZSubscribeKey("APP_ON_HIDE")
    
    public static let themeChangeSubscribeKey = NZSubscribeKey("APP_THEME_CHANGE")
    
}

//MARK: Equatable
extension NZAppService: Equatable {
    
    public static func == (lhs: NZAppService, rhs: NZAppService) -> Bool {
        return lhs.runningId == rhs.runningId
    }

}
