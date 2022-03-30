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
    
    public let appInfo: NZAppInfo
               
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
                uiControl.addMiniProgramNavigationBarButton(to: rootViewController.view)
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
        self.launchOptions = launchOptions
        self.config = config
        
        context.name = "\(appId) - app-service"
        
        bridge = NZJSBridge(appService: self, container: context)

        setupModules()
        
        webViewPool = NZPool(autoGenerateWithEmpty: true) { [unowned self] in
            return self.createWebView()
        }
        
        uiControl.closeHandler = { [unowned self] in
            self.closeMiniProgram()
        }
        
        uiControl.gotoHomeHandler = { [unowned self] in
            self.gotoHomePage()
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
                    self.uiControl.addTabBar(to: viewController.view)
                }
            } else {
                self.rootViewController?.viewControllers = [viewController]
                if page.isShowTabBar {
                    self.uiControl.addTabBar(to: viewController.view)
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
                  let callbackId = message["callbackId"] as? Int
            else { return }
            let args = NZJSBridge.InvokeArgs(eventName: event,
                                    paramsString: params,
                                    callbackId: callbackId)
            self.bridge.onInvoke(args)
        }
        
        context.publishHandler = { [unowned self] message in
            guard let event = message["event"] as? String,
                  let webViewId = message["webViewId"] as? Int,
                  let params = message["params"] as? String,
                  let page = self.findWebPage(from: webViewId)
            else { return }
            page.webView.bridge.subscribeHandler(method: NZSubscribeKey(event),
                                                data: params,
                                                webViewId: webViewId)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
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
            uiControl.addGotoHomeButton(to: navigationController.view)
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
            context.evaluateScript("globalThis.__NZConfig.appName = '\(appInfo.appName)';")
        } else {
            NZLogger.error("load app code failed: \(appServiceURL.path) file not exist")
        }
    }
    
    func genPageId() -> Int {
        incPageId += 1
        return incPageId
    }
    
    public func findWebPage(from pageId: Int) -> NZWebPage? {
        guard let page = pages.first(where: { $0.pageId == pageId }) as? NZWebPage else { return nil }
        return page
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
    
    @objc public func killApp() {
        cleanKillTimer()
        context.clearAllTimer()
        cleanAllPages()
        rootViewController = nil
        if haveTabBar {
            tabBarPages = []
            uiControl.tabBarViewControllers = [:]
        }
        currentPage = nil
        modules.values.forEach { $0.willExitApp(self) }
        modules = [:]
        
        if let index = NZEngine.shared.runningApp.firstIndex(of: self) {
            NZEngine.shared.runningApp.remove(at: index)
        }
        if NZEngine.shared.currentApp === self {
            NZEngine.shared.currentApp = nil
        }
    }
    
    func cleanPage(_ page: NZPage) {
        modules.values.forEach { $0.willExitPage(page) }
        if let webPage = page as? NZWebPage {
            webPage.onUnload()
        }
        if let index = pages.firstIndex(where: { $0.pageId == page.pageId }) {
            pages.remove(at: index)
        }
    }
    
    func cleanAllPages() {
        pages.forEach { page in
            modules.values.forEach { $0.willExitPage(page) }
            if let webPage = page as? NZWebPage {
                webPage.onUnload()
            }
        }
        pages = []
    }
    
    func cleanCurrentPage() {
        guard let currentPage = currentPage else { return }

        modules.values.forEach { $0.willExitPage(currentPage) }
        if let currentPage = currentPage as? NZWebPage {
            currentPage.onUnload()
        }
    }
    
    func cleanKillTimer() {
        killTimer?.invalidate()
        killTimer = nil
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
            cleanAllPages()
            uiControl.setupTabBar(config: config, envVersion: envVersion)
            uiControl.tabBarView.setTabItemSelect(info.tabBarSelectedIndex)
            uiControl.tabBarViewControllers = [:]
            uiControl.tabBarViewControllers[info.page.url] = info.viewController
            tabBarPages = info.tabBarPages
            pages.append(info.page)
            rootViewController?.viewControllers = [info.viewController]
            uiControl.addTabBar(to: info.viewController.view)
            uiControl.removeGotoHomeButton()
        } else if let firstPage = config.pages.first,
                  let page = createWebPage(url: firstPage.path) {
            cleanAllPages()
            pages.append(page)
            let viewController = page.generateViewController()
            rootViewController?.viewControllers = [viewController]
            uiControl.removeGotoHomeButton()
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
    }
    
    func publishAppOnShow(path: String) {
        cleanKillTimer()
        let message: [String: Any] = ["path": path]
        bridge.subscribeHandler(method: NZAppService.onShowSubscribeKey, data: message)
    }
    
    @objc private func willEnterForeground() {
        publishAppOnShow(path: "")
    }
    
    @objc private func didEnterBackground() {
        publishAppOnHide()
    }
    
    @objc func publishAppOnHide() {
        let message: [String: Any] = [:]
        bridge.subscribeHandler(method: NZAppService.onHideSubscribeKey, data: message)
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
                cleanAllPages()
                uiControl.tabBarViewControllers = [:]
                pages.append(info.page)
                rootViewController.viewControllers = [info.viewController]
                uiControl.addGotoHomeButton(to: rootViewController.view)
            } else {
                cleanPage(currentPage)
                pages.append(info.page)
                rootViewController.viewControllers.removeLast()
                rootViewController.viewControllers.append(info.viewController)
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
        cleanAllPages()
        
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
            uiControl.addGotoHomeButton(to: rootViewController.view)
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
    
}

//MARK: Equatable
extension NZAppService: Equatable {
    
    public static func == (lhs: NZAppService, rhs: NZAppService) -> Bool {
        return lhs.runningId == rhs.runningId
    }

}
