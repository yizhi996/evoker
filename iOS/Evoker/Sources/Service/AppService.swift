//
//  AppService.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import JavaScriptCore
import WebKit
import Alamofire

final public class AppService {
    
    public enum State: Int {
        case front = 0
        case back
        case suspend
    }
    
    public let config: AppConfig
    
    public private(set) var appInfo: AppInfo
               
    public internal(set) var launchOptions: AppLaunchOptions
    
    public var appId: String {
        return config.appId
    }
    
    public var envVersion: AppEnvVersion {
        return launchOptions.envVersion
    }
    
    public var haveTabBar: Bool {
        return config.tabBar?.list.isEmpty == false
    }

    public internal(set) var state: State = .back
    
    public internal(set) var currentPage: Page?
    
    public internal(set) var pages: [Page] = []
    
    public private(set) var bridge: JSBridge!
    
    public let uiControl = AppUIControl()
    
    public lazy var storage: AppStorage = {
        return AppStorage(appId: appId)
    }()
    
    public internal(set) var rootViewController: NavigationController? {
        didSet {
            if let rootViewController = rootViewController {
                rootViewController.themeChangeHandler = { [unowned self] theme in
                    self.bridge.subscribeHandler(method: Self.themeChangeSubscribeKey, data: ["theme": theme])
                }
                uiControl.capsuleView.add(to: rootViewController.view)
            }
        }
    }
    
    public lazy var tabBarPages: [Page] = []
    
    public lazy var requests: [String: Request] = [:]
    
    public internal(set) var modules: [String: Module] = [:]
    
    public private(set) lazy var localImageCache = LRUCache<String, String>(maxSize: 1024 * 1024 * 100)
    
    private var incPageId = 0
    
    private var killTimer: Timer?
    
    lazy var context: JSContext = {
        return Engine.shared.jsContextPool.idle()
    }()
    
    var webViewPool: Pool<WebView>!
    
    var keepScreenOn = false
    
    init?(appId: String, appInfo: AppInfo, launchOptions: AppLaunchOptions) {
        guard !appId.isEmpty,
              let config = AppConfig.load(appId: appId, envVersion: launchOptions.envVersion),
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
        
        bridge = JSBridge(appService: self, container: context)

        setupModules()
        
        webViewPool = Pool(autoGenerateWithEmpty: true) { [unowned self] in
            return self.createWebView()
        }
        
        uiControl.capsuleView.clickCloseHandler = { [unowned self] in
            self.supend()
        }
        
        uiControl.capsuleView.clickMoreHandler = { [unowned self] in
            guard let rootViewController = self.rootViewController else { return }
            if let module: InputModule = self.getModule() {
                if let input = module.inputs.all().first(where: { $0.isFirstResponder }) {
                    input.endEdit()
                }
            }
            Engine.shared.shouldInteractivePopGesture = false
            self.uiControl.showAppMoreActionBoard(appService: self, to: rootViewController.view, cancellationHandler: {
                Engine.shared.shouldInteractivePopGesture = true
            }) { action in
                Engine.shared.shouldInteractivePopGesture = true
                self.invokeAppMoreAction(action)
            }
        }
        
        context.invokeHandler = { [unowned self] message in
            guard let event = message["event"] as? String,
                  let params = message["params"] as? String,
                  let callbackId = message["callbackId"] as? Int else { return }
            let args = JSBridge.InvokeArgs(eventName: event,
                                    paramsString: params,
                                    callbackId: callbackId)
            self.bridge.onInvoke(args)
        }
        
        context.publishHandler = { [unowned self] message in
            guard let event = message["event"] as? String,
                  let webViewId = message["webViewId"] as? Int,
                  let params = message["params"] as? String,
                  let page = self.findWebPage(from: webViewId) else { return }
            page.webView.bridge.subscribeHandler(method: SubscribeKey(event),
                                                data: params,
                                                webViewId: webViewId)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusDidChange(_:)),
                                               name: Engine.networkStatusDidChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidTakeScreenshot),
                                               name: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil)
    }
    
    deinit {
        Logger.debug("\(appId) app service deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didReceiveMemoryWarning() {
        localImageCache.removeAll()
    }
    
    func setupModules() {
        Engine.shared.allModules().forEach { modules[$0.name] = $0.init(appService: self) }
    }
    
    func launch(to viewController: UIViewController? = nil) -> EKError? {
        let path = launchOptions.path
        guard let info = generateFirstViewController(with: path) else { return .appLaunchPathNotFound(path) }
        
        if let error = loadAppPackage() {
            return error
        }
        
        if haveTabBar {
            setupTabBar(current: info.tabBarSelectedIndex)
            if info.page.isTabBarPage {
                uiControl.tabBarViewControllers[info.page.url] = info.viewController
            }
            tabBarPages = info.tabBarPages
        }
        
        currentPage = info.page
        pages.append(info.page)
        
        waitPageFirstRendered(page: info.page) { }
        
        publishAppOnLaunch(options: launchOptions)
        
        let navigationController = NavigationController(rootViewController: info.viewController)
        navigationController.modalPresentationStyle = .fullScreen
        if info.needAddGotoHomeButton {
            info.viewController.navigationBar.showGotoHomeButton()
        }
        rootViewController = navigationController
        
        let presentViewController = viewController ?? UIViewController.visibleViewController()
        presentViewController?.present(navigationController, animated: true)
        if info.page.isTabBarPage {
            uiControl.tabBarView.add(to: info.viewController.view)
        }
        state = .front
        
        var showOptions = AppShowOptions()
        showOptions.path = path
        showOptions.referrerInfo = launchOptions.referrerInfo
        publishAppOnShow(options: showOptions)
        return nil
    }
    
    func loadAppPackage() -> EKError? {
        let configScript = JavaScriptGenerator.defineConfig(appConfig: config)
        let appInfoScript = JavaScriptGenerator.setAppInfo(appInfo: appInfo)
        context.evaluateScript(configScript + appInfoScript)
        
        let dist = FilePath.appDist(appId: appId, envVersion: launchOptions.envVersion)
        let fileName = "app-service.js"
        let appServiceURL = dist.appendingPathComponent(fileName)
        if let js = try? String(contentsOfFile: appServiceURL.path) {
            context.evaluateScript(js, name: fileName)
        } else {
            Logger.error("load app code failed: \(appServiceURL.path) file not exist")
            return EKError.appServiceBundleNotFound
        }
        return nil
    }
    
    func genPageId() -> Int {
        incPageId += 1
        return incPageId
    }
    
    public func findWebPage(from pageId: Int) -> WebPage? {
        return pages.first(where: { $0.pageId == pageId }) as? WebPage
    }
    
    public func getModule<T: Module>() -> T? {
        return modules[T.name] as? T
    }
    
    public func reLaunch(launchOptions: AppLaunchOptions? = nil) {
        dismiss(animated: false) {
            self.killApp()
            if Engine.shared.config.dev.useDevServer {
                Engine.shared.webViewPool.clean()
            }
            let launchOptions = launchOptions ?? self.launchOptions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                Engine.shared.launchApp(appId: self.appId, launchOptions: launchOptions) { error in
                    if let error = error {
                        Logger.error(error.localizedDescription)
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
        pages.filter(ofType: WebPage.self).reversed().forEach { $0.publishOnUnload() }
        pages = []
        rootViewController = nil
        if haveTabBar {
            tabBarPages = []
            uiControl.tabBarViewControllers = [:]
        }
        currentPage = nil
        modules.values.forEach { $0.onExit(self) }
        modules = [:]
        context.exit()
        
        webViewPool.clean { webView in
            webView.removeFromSuperview()
        }
        
        if let index = Engine.shared.runningApp.firstIndex(of: self) {
            Engine.shared.runningApp.remove(at: index)
        }
        
        if Engine.shared.currentApp === self {
            Engine.shared.currentApp = nil
        }
    }
    
    func cleanKillTimer() {
        killTimer?.invalidate()
        killTimer = nil
    }
    
    @objc
    private func networkStatusDidChange(_ notification: Notification) {
        guard let netType = notification.object as? NetworkType else { return }
        bridge.subscribeHandler(method: AppService.networkStatusChangeSubscribeKey, data: [
            "isConnected": netType != .none,
            "networkType": netType.rawValue
        ])
    }
    
    @objc
    private func userDidTakeScreenshot() {
        bridge.subscribeHandler(method: AppService.userCaptureScreenSubscribeKey, data: [:])
    }
}

extension AppService {
    
    struct GenerateFirstViewControllerInfo {
        let page: Page
        let viewController: PageViewController
        let tabBarSelectedIndex: Int
        let needAddGotoHomeButton: Bool
        let tabBarPages: [Page]
    }
    
    func generateFirstViewController(with path: String) -> GenerateFirstViewControllerInfo? {
        var route = path
        var query = ""
        if let queryIndex = path.firstIndex(of: "?") {
            route = String(path[path.startIndex..<queryIndex])
            query = String(path[queryIndex..<path.endIndex])
        }
        
        var tabBarPages: [WebPage] = []
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
                    page.tabIndex = UInt8(i)
                    tabBarPages.append(page)
                }
            }
        }
        
        var firstTabBarPage: Page?
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
extension AppService {
    
    func waitPageFirstRendered(page: Page, finishHandler: @escaping () -> Void) {
        if let webPage = page as? WebPage {
            var isRendered = false
            let exec: () -> Void = {
                if !isRendered {
                    isRendered = true
                    webPage.publishOnReady()
                    finishHandler()
                }
            }
            webPage.webView.firstRenderCompletionHandler = exec
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: exec)
        } else {
            finishHandler()
        }
    }
    
    func setupTabBar(current index: Int) {
        uiControl.tabBarView.load(config: config, envVersion: envVersion)
        uiControl.tabBarView.didSelectTabBarItemHandler = { [unowned self] index in
            self.didSelectTabBarItem(at: index, fromTap: true)
        }
        uiControl.tabBarView.setTabItemSelected(index)
        uiControl.tabBarViewControllers = [:]
    }
    
    func didSelectTabBarItem(at index: Int, fromTap: Bool) {
        let page = tabBarPages[index]
        if !pages.contains(where: { $0.pageId == page.pageId }) {
            pages.append(page)
        }
        
        if let webPage = page as? WebPage, page.viewController != nil {
            let text = self.uiControl.tabBarView.tabBarItems[index].titleLabel?.text ?? ""
            self.bridge.subscribeHandler(method: WebPage.onTabItemTapSubscribeKey, data: ["pageId": webPage.pageId,
                                                                                          "index": index,
                                                                                          "pagePath": webPage.route,
                                                                                          "text": text,
                                                                                          "fromTap": fromTap])
        }
        
        if currentPage === page {
            return
        }
        
        if let prevPage = currentPage as? WebPage {
            prevPage.publishOnHide()
        }
        currentPage = page
        
        let viewController = page.viewController ?? page.generateViewController()
        uiControl.tabBarViewControllers[page.url] = viewController
        
        let switchTo: () -> Void = {
            self.rootViewController?.viewControllers = [viewController]
            if page.isShowTabBar {
                self.uiControl.tabBarView.add(to: viewController.view)
                self.uiControl.tabBarView.setTabItemSelected(index)
            }
        }
        
        if !viewController.isViewLoaded {
            if let webPage = page as? WebPage {
                webPage.isFromTabItemTap = fromTap
            }
            waitPageFirstRendered(page: page, finishHandler: switchTo)
        } else {
            if let webPage = page as? WebPage {
                webPage.publishOnShow()
            }
            switchTo()
        }
    }
    
    func checkAddGotoHomeButton(path: String) -> Bool {
        let (route, _) = path.decodeURL()
        if let tabBarList = config.tabBar?.list, !tabBarList.isEmpty {
            return !tabBarList.contains(where: { $0.path == route })
        }
        return config.pages.first?.path != route
    }
    
    /// 返回到首页，如果有 TabBar，将返回到第一个 Tab，不然就返回 config.pages 的第一个 page。
    public func gotoHomePage() {
        if let firstTabBar = config.tabBar?.list.first, let info = generateFirstViewController(with: firstTabBar.path) {
            pages.filter(ofType: WebPage.self).reversed().forEach { $0.publishOnUnload() }
            pages = [info.page]
            currentPage = info.page
            waitPageFirstRendered(page: info.page) {
                self.setupTabBar(current: info.tabBarSelectedIndex)
                self.uiControl.tabBarViewControllers[info.page.url] = info.viewController
                self.tabBarPages = info.tabBarPages
                self.rootViewController?.viewControllers = [info.viewController]
                self.uiControl.tabBarView.add(to: info.viewController.view)
            }
        } else if let firstPage = config.pages.first,
                  let page = createWebPage(url: firstPage.path) {
            pages.filter(ofType: WebPage.self).reversed().forEach { $0.publishOnUnload() }
            pages = [page]
            currentPage = page
            let viewController = page.generateViewController()
            waitPageFirstRendered(page: page) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.rootViewController?.viewControllers = [viewController]
                }
            }
        }
    }
    
    /// 隐藏小程序到后台，如果 15 分钟内没有进如前台，小程序将退出。
    public func supend() {
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
    
    /// 获取当前页面的 onShareAppMessage 返回的内容
    ///
    /// 返回的内容在 Engine.shared.config.hooks.app.shareAppMessage 中接收
    public func fetchShareAppMessageContent() {
        if let page = currentPage as? WebPage {
            bridge.subscribeHandler(method: Self.fetchShareAppMessageContentSubscribeKey,
                                    data: ["pageId": page.pageId, "from": "menu"])
        }
    }
    
    func invokeAppMoreAction(_ action: AppMoreAction) {
        switch action.key {
        case AppMoreAction.builtInSettingsKey:
            let viewModel = SettingViewModel(appService: self)
            rootViewController?.pushViewController(viewModel.generateViewController(), animated: true)
            break
        case AppMoreAction.builtInReLaunchKey:
            var options = AppLaunchOptions()
            options.envVersion = envVersion
            reLaunch(launchOptions: options)
        case AppMoreAction.builtInShareKey:
            fetchShareAppMessageContent()
        default:
            Engine.shared.config.hooks.app.clickAppMoreAction?(self, action)
        }
    }
}

//MARK: WebView
extension AppService {
    
    func createWebView() -> WebView {
        let webView = Engine.shared.createWebView()
        loadAppCSS(to: webView)
        return webView
    }
    
    func preloadWebView() {
        let webView = createWebView()
        webViewPool.push(webView)
    }
    
    func loadAppCSS(to webView: WebView) {
        webView.runAfterLoad { [weak self] in
            guard let self = self else { return }
            
            self.config.chunkCSS?.forEach { css in
                let path = FilePath.appDist(appId: self.appId,
                                              envVersion: self.envVersion).appendingPathComponent(css).absoluteString
                let script = JavaScriptGenerator.injectCSS(path: path)
                webView.evaluateJavaScript(script) { _, error in
                    if let error = error as? WKError, error.code != .javaScriptResultTypeIsUnsupported {
                        Logger.error("WebView eval \(script) failed: \(error)")
                    }
                }
            }
        }
    }
    
    func recycle(webView: WebView) {
        webViewPool.clean { webView in
            webView.removeFromSuperview()
        }
        webView.recycle()
        loadAppCSS(to: webView)
        webViewPool.push(webView)
    }
    
    public func idleWebView() -> WebView {
        let webView =  webViewPool.idle()
        webView.removeFromSuperview()
        return webView
    }
}

//MARK: App Life cycle publish
extension AppService {
    
    func setEnterOptions(options: AppEnterOptions) -> [String: Any] {
        launchOptions.path = options.path
        launchOptions.referrerInfo = options.referrerInfo
        
        var message: [String: Any] = ["path": options.path]
        if let referrerInfo = options.referrerInfo {
            message["referrerInfo"] = ["appId": referrerInfo.appId, "extraDataString": referrerInfo.extraDataString]
        } else {
            message["referrerInfo"] = [:]
        }
        return message
    }
    
    func publishAppOnLaunch(options: AppLaunchOptions) {
        bridge.subscribeHandler(method: AppService.onLaunchSubscribeKey, data: setEnterOptions(options: options))
        Engine.shared.config.hooks.appLifeCycle.onLaunch?(self, options)
        modules.values.forEach { $0.onLaunch(self, options: options) }
    }
    
    func publishAppOnShow(options: AppShowOptions) {
        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        cleanKillTimer()
        bridge.subscribeHandler(method: AppService.onShowSubscribeKey, data: setEnterOptions(options: options))
        Engine.shared.config.hooks.appLifeCycle.onShow?(self, options)
        modules.values.forEach { $0.onShow(self, options: options) }
    }
    
    @objc
    func publishAppOnHide() {
        UIApplication.shared.isIdleTimerDisabled = false
        bridge.subscribeHandler(method: AppService.onHideSubscribeKey, data: [:])
        Engine.shared.config.hooks.appLifeCycle.onHide?(self)
        modules.values.forEach { $0.onHide(self) }
    }
}

extension AppService {
    
    func createWebPage(url: String) -> WebPage? {
        return Engine.shared.config.classes.webPage.init(appService: self, url: url)
    }
    
    func createBrowserPage(url: String) -> BrowserPage? {
        return Engine.shared.config.classes.browserPage.init(appService: self, url: url)
    }
}

public extension AppService {
    
    func push(_ page: Page, animated: Bool = true, completedHandler: EmptyBlock? = nil) {
        pages.append(page)
        
        if let prevPage = currentPage as? WebPage {
            prevPage.publishOnHide()
        }
        currentPage = page
        
        let viewController = page.generateViewController()
        viewController.loadCompletedHandler = {
            completedHandler?()
        }
        
        waitPageFirstRendered(page: page) {
            // 不使用 CATransaction 会有一定几率造成跳转延迟或者动画消失
            CATransaction.begin()
            self.rootViewController?.pushViewController(viewController, animated: true)
            CATransaction.commit()
        }
    }
    
    func redirectTo(_ url: String) -> EKError? {
        let (path, _) = url.decodeURL()
        
        if let tabBar = config.tabBar, tabBar.list.contains(where: { $0.path == path }) {
            return .bridgeFailed(reason: .cannotToTabbarPage)
        }
        
        guard let rootViewController = rootViewController else {
            return .appRootViewControllerNotFound
        }
        
        guard let info = generateFirstViewController(with: url) else {
            return .appLaunchPathNotFound(path)
        }
        
        if let prevPage = currentPage {
            if prevPage.isTabBarPage {
                pages.filter(ofType: WebPage.self).reversed().forEach { $0.publishOnUnload() }
                
                pages = [info.page]
                
                currentPage = info.page
                waitPageFirstRendered(page: info.page) {
                    self.uiControl.tabBarViewControllers = [:]
                    rootViewController.viewControllers = [info.viewController]
                    if info.needAddGotoHomeButton {
                        info.viewController.navigationBar.showGotoHomeButton()
                    }
                }
            } else {
                if let webPage = prevPage as? WebPage {
                    webPage.publishOnUnload()
                }
                pages.append(info.page)
                currentPage = info.page
                waitPageFirstRendered(page: info.page) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        rootViewController.viewControllers[rootViewController.viewControllers.count - 1] = info.viewController
                        if self.pages.count == 1 {
                            info.viewController.navigationBar.showGotoHomeButton()
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func pop(delta: Int = 1, animated: Bool = true) {
        guard let rootViewController = rootViewController else { return }
        
        guard rootViewController.viewControllers.count > 1 else { return }
        
        if delta <= 1 {
            if let lastViewController = rootViewController.viewControllers.last as? WebPageViewController {
                lastViewController.webPage.publishOnUnload()
            }
            
            let index = rootViewController.viewControllers.count - 2
            currentPage = (rootViewController.viewControllers[index] as! PageViewController).page
            rootViewController.popViewController(animated: true)
        } else if rootViewController.viewControllers.count > delta {
            let viewControllers = Array(rootViewController.viewControllers.reversed())
            let viewController = viewControllers[delta]
            Array(viewControllers[0..<delta])
                .filter(ofType: WebPageViewController.self)
                .forEach { $0.webPage.publishOnUnload() }
            
            currentPage = (viewController as! PageViewController).page
            rootViewController.popToViewController(viewController, animated: true)
        } else {
            Array(rootViewController.viewControllers[1..<rootViewController.viewControllers.count].reversed())
                .filter(ofType: WebPageViewController.self)
                .forEach { $0.webPage.publishOnUnload() }
            
            currentPage = (rootViewController.viewControllers[0] as! PageViewController).page
            rootViewController.popToRootViewController(animated: true)
        }
        
        if let webPage = currentPage as? WebPage {
            webPage.publishOnShow()
        }
    }
    
    func dismiss(animated: Bool = true, completion: EmptyBlock? = nil) {
        if let webPage = currentPage as? WebPage {
            webPage.publishOnHide()
        }
        publishAppOnHide()
        rootViewController?.dismiss(animated: animated, completion: completion)
    }
    
    func reLaunch(url: String) -> EKError? {
        guard let rootViewController = rootViewController else { return .appRootViewControllerNotFound }
        guard let info = generateFirstViewController(with: url) else { return .appLaunchPathNotFound(url) }
        
        currentPage = nil
        
        if haveTabBar {
            setupTabBar(current: info.tabBarSelectedIndex)
            if info.page.isTabBarPage {
                uiControl.tabBarViewControllers[info.page.url] = info.viewController
            }
            tabBarPages = info.tabBarPages
        }
        
        pages.filter(ofType: WebPage.self).reversed().forEach { $0.publishOnUnload() }
        pages = [info.page]
        currentPage = info.page
        
        waitPageFirstRendered(page: info.page) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                rootViewController.viewControllers = [info.viewController]
                
                if info.page.isTabBarPage {
                    self.uiControl.tabBarView.add(to: info.viewController.view)
                }
                if info.needAddGotoHomeButton {
                    info.viewController.navigationBar.showGotoHomeButton()
                }
            }
        }
        
        return nil
    }
    
    func switchTo(url: String) {
        if let index = tabBarPages.filter(ofType: WebPage.self).firstIndex(where: { $0.url == url }) {
            didSelectTabBarItem(at: index, fromTap: false)
        }
    }
}

//MARK: SubscribeKey
extension AppService {
    
    public static let onLaunchSubscribeKey = SubscribeKey("APP_ON_LAUNCH")
    
    public static let onShowSubscribeKey = SubscribeKey("APP_ON_SHOW")
    
    public static let onHideSubscribeKey = SubscribeKey("APP_ON_HIDE")
    
    public static let themeChangeSubscribeKey = SubscribeKey("APP_THEME_CHANGE")
    
    public static let onAudioInterruptionBeginSubscribeKey = SubscribeKey("APP_ON_AUDIO_INTERRUPTION_BEGIN")
    
    public static let onAudioInterruptionEndSubscribeKey = SubscribeKey("APP_ON_AUDIO_INTERRUPTION_END")
    
    public static let networkStatusChangeSubscribeKey = SubscribeKey("APP_NETWORK_STATUS_CHANGE")
    
    public static let userCaptureScreenSubscribeKey = SubscribeKey("APP_USER_CAPTURE_SCREEN")
    
    public static let fetchShareAppMessageContentSubscribeKey = SubscribeKey("FETCH_SHARE_APP_MESSAGE_CONTENT")
    
}

//MARK: Equatable
extension AppService: Equatable {
    
    public static func == (lhs: AppService, rhs: AppService) -> Bool {
        return lhs.appId == rhs.appId && lhs.envVersion == rhs.envVersion
    }

}
