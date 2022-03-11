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

    public internal(set) var state: State = .back
    
    public internal(set) var currentPage: NZPage?
    
    public internal(set) var pages: [NZPage] = []
    
    public private(set) var bridge: NZJSBridge!
    
    public lazy var storage: NZAppStorage = {
        return NZAppStorage(appId: appId, envVersion: launchOptions.envVersion)
    }()
    
    public internal(set) var rootViewController: NZNavigationController? {
        didSet {
            if let rootViewController = rootViewController {
                addMiniProgramNavigationBarButton(to: rootViewController.view)
            }
        }
    }
    
    public lazy var tabBarControllers: [NZPageViewController] = []
    
    public lazy var tabBarView = NZTabBarView()
    
    public lazy var requests: [Int: Request] = [:]
    
    public internal(set) var modules: [String: NZModule] = [:]
    
    private var incPageId = 0
    
    private var killTimer: Timer?
    
    public internal(set) var gotoHomeButton: UIButton?
    
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
    
    func launch(path: String) -> NZError? {
        let (fitstViewController, needAddGoHomeButton) = getAppFirstViewController(path: path)
        guard let fitstViewController = fitstViewController else { return NZError.appLaunchPathNotFound(path) }
        setupTabBarView()
        loadAppPackage()
        publishAppOnLaunch(path: path)
        
        let navigationController = NZNavigationController(rootViewController: fitstViewController)
        navigationController.modalPresentationStyle = .fullScreen
        if needAddGoHomeButton {
            addGotoHomeButton(to: navigationController.view)
        }
        rootViewController = navigationController
        let visibleViewController = UIViewController.visibleViewController()
        visibleViewController?.present(navigationController, animated: true)
        state = .front
        publishAppOnShow(path: path)
        return nil
    }
    
    func loadAppPackage() {
        let dist = FilePath.appDist(appId: appId, envVersion: launchOptions.envVersion)
        let appServiceURL = dist.appendingPathComponent("app-service.js")
        if let js = try? String(contentsOfFile: appServiceURL.path) {
            context.evaluateScript(js, name: "app-service.js")
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
    
    public func relaunch(launchOptions: NZAppLaunchOptions? = nil) {
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
        tabBarControllers = []
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
    
    func cleanNotTabPages() {
        pages.filter { !$0.isTabBarPage }.forEach { page in
            modules.values.forEach { $0.willExitPage(page) }
            if let webPage = page as? NZWebPage {
                webPage.onUnload()
            }
        }
        pages = pages.filter { $0.isTabBarPage }
    }
    
    func cleanKillTimer() {
        killTimer?.invalidate()
        killTimer = nil
    }
}

extension NZAppService {
    
    func getAppFirstViewController(path: String) -> (UIViewController?, Bool) {
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
                
                if let page = createWebPage(path: pagePath) {
                    page.isTabBarPage = true
                    tabBarPages.append(page)
                }
            }
        }
        
        var firstViewController: UIViewController?
        
        let tabBarViewControllers = tabBarPages.map { page -> UIViewController in
            let viewController = page.generateViewController()
            tabBarControllers.append(viewController)
            if !path.isEmpty && page.path == path {
                firstViewController = viewController
                tabBarView.setTabItemSelect(tabBarControllers.count - 1)
            }
            return viewController
        }
        
        // 打开指定 tab
        if firstViewController != nil {
            return (firstViewController, false)
        }
        
        // 打开首个 tab
        if route.isEmpty && firstViewController == nil && !tabBarViewControllers.isEmpty {
            tabBarView.setTabItemSelect(0)
            return (tabBarViewControllers[0], false)
        }
        
        // 打开指定 page
        if config.pages.contains(where: { $0.path == route }), let page = createWebPage(path: path) {
            let viewController = page.generateViewController()
            return (viewController, checkAddGotoHomeButton(path: path))
        } else if let first = config.pages.first { // 打开首页
            let pagePath = first.path + query
            if let page = createWebPage(path: pagePath) {
                let viewController = page.generateViewController()
                return (viewController, false)
            }
        }
        
        return (nil, false)
    }
}

//MARK: View
extension NZAppService {
    
    func setupTabBarView() {
        if let tabBarInfo = config.tabBar, !tabBarInfo.list.isEmpty {
            tabBarView.backgroundColor = tabBarInfo.backgroundColor.hexColor()
            tabBarView.load(config: config, envVersion: envVersion)
            tabBarView.didSelectIndex = { [unowned self] index in
                let viewController = self.tabBarControllers[index]
                if !viewController.isViewLoaded {
                    viewController.loadViewIfNeeded()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.rootViewController?.viewControllers = [viewController]
                    }
                } else {
                    self.rootViewController?.viewControllers = [viewController]
                }
            }
        }
    }
    
    func checkAddGotoHomeButton(path: String) -> Bool {
        let (route, _) = path.decodeURL()
        if let tabBarList = config.tabBar?.list, !tabBarList.isEmpty {
            return !tabBarList.contains(where: { $0.path == route })
        }
        return config.pages.first?.path != route
    }
    
    func addGotoHomeButton(to view: UIView) {
        let homeIcon = UIImage(builtIn: "mini-program-home-icon")?.withRenderingMode(.alwaysOriginal)
        let button = UIButton()
        button.setImage(homeIcon, for: .normal)
        button.addTarget(self, action: #selector(gotoHomePage), for: .touchUpInside)
        view.addSubview(button)
        let safeAreaTop = Constant.safeAreaInsets.top
        let buttonSize = 32.0
        let top = safeAreaTop + (Constant.navigationBarHeight - buttonSize) / 2
        button.autoPinEdge(toSuperviewEdge: .top, withInset: top)
        button.autoPinEdge(toSuperviewEdge: .left, withInset: 7)
        button.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))
        
        gotoHomeButton = button
    }
    
    func removeGotoHomeButton() {
        gotoHomeButton?.removeFromSuperview()
    }
    
    func addMiniProgramNavigationBarButton(to view: UIView) {
        let actionView = MiniProgramNavigationBar()
        actionView.closeButton.addTarget(self, action: #selector(closeMiniProgram), for: .touchUpInside)
        actionView.moreButton.addTarget(self, action: #selector(openMoreActionBoard), for: .touchUpInside)
        view.addSubview(actionView)
        let safeAreaTop = Constant.safeAreaInsets.top
        let top = safeAreaTop + (Constant.navigationBarHeight - actionView.buttonHeight) / 2
        actionView.autoPinEdge(toSuperviewEdge: .top, withInset: top)
        actionView.autoPinEdge(toSuperviewEdge: .right, withInset: 7)
    }
    
    @objc func gotoHomePage() {
        if let fitstViewController = tabBarControllers.first {
            cleanNotTabPages()
            rootViewController?.viewControllers = [fitstViewController]
            tabBarView.setTabItemSelect(0)
            removeGotoHomeButton()
        } else if let firstPage = config.pages.first,
                  let page = createWebPage(path: firstPage.path) {
            cleanAllPages()
            let viewController = page.generateViewController()
            rootViewController?.viewControllers = [viewController]
            removeGotoHomeButton()
        }
    }
    
    @objc func closeMiniProgram() {
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
    
    @objc func openMoreActionBoard() {
        guard let viewController = rootViewController else { return }

        let firstActions: [NZMiniProgramAction] = []
        let settingsAction = NZMiniProgramAction(key: "settings",
                                                 icon: nil,
                                                 iconImage: UIImage(builtIn: "mp-action-sheet-setting-icon"),
                                                 title: "设置")
        let relaunchAction = NZMiniProgramAction(key: "relaunch",
                                                 icon: nil,
                                                 iconImage: UIImage(builtIn: "mp-action-sheet-reload-icon"),
                                                 title: "重新进入小程序")
        let secondActions = [settingsAction, relaunchAction]
        let params = NZMiniProgramActionSheet.Params(appId: appId,
                                                     appName: appInfo.appName,
                                                     appIcon: appInfo.appIconURL,
                                                     firstActions: firstActions,
                                                     secondActions: secondActions)
        let cover = NZCoverView()
        let actionSheet = NZMiniProgramActionSheet(params: params)
        let onHide = {
            actionSheet.hide()
            cover.hide()
        }
        cover.clickHandler = {
            onHide()
        }
        actionSheet.didSelectActionHandler = { [unowned self] action in
            onHide()
            switch action.key {
            case "settings":
                break
            case "relaunch":
                var options = NZAppLaunchOptions()
                options.envVersion = self.envVersion
                self.relaunch(launchOptions: options)
            default: break
            }
        }
        actionSheet.onCancel = {
            onHide()
        }
        
        viewController.view.endEditing(true)
        cover.show(to: viewController.view)
        actionSheet.show(to: cover)
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
    
    func createWebPage(path: String) -> NZWebPage? {
        guard let page = NZEngine.shared.config.webPageClass.init(appService: self, path: path) else { return nil }
        pages.append(page)
        return page
    }
    
    func createBrowserPage(url: String, cookies: String = "") -> NZBrowserPage? {
        guard let page = NZEngine.shared.config.browserPageClass.init(appService: self, url: url, cookies: cookies) else { return nil }
        pages.append(page)
        return page
    }
}

public extension NZAppService {
    
    func push(_ page: NZPage, animated: Bool = true, completedHandler: NZEmptyBlock? = nil) {
        let viewController = page.generateViewController()
        viewController.loadCompletedHandler = {
            completedHandler?()
        }
        viewController.loadViewIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.rootViewController?.pushViewController(viewController, animated: true)
        }
    }
    
    func present(_ page: NZPage, animated: Bool = true, addNavigation: Bool = true) {
        var viewController = page.generateViewController() as UIViewController
        if addNavigation {
            viewController = NZNavigationController(rootViewController: viewController)
        }
        rootViewController?.present(viewController, animated: animated, completion: nil)
    }
    
    func redirectTo(_ path: String) {
        guard let rootViewController = rootViewController else { return }
        
        cleanAllPages()
        tabBarControllers = []
        
        let (viewController, addGoToHomeButton) = getAppFirstViewController(path: path)
        if let viewController = viewController {
            rootViewController.viewControllers = [viewController]
            if addGoToHomeButton {
                addGotoHomeButton(to: rootViewController.view)
            }
        }
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
    
    func reLaunch(path: String) {
        currentPage = nil
        cleanAllPages()
        tabBarControllers = []
        
        let (fitstViewController, needAddGoHomeButton) = getAppFirstViewController(path: path)
        guard let fitstViewController = fitstViewController else { return }
        guard let rootViewController = rootViewController else { return }
        if needAddGoHomeButton {
            addGotoHomeButton(to: rootViewController.view)
        }
        rootViewController.viewControllers = [fitstViewController]
    }
    
    func switchTo(url: String) {
        let index = tabBarControllers.filter(ofType: NZWebPageViewController.self)
            .firstIndex { $0.webPage.route == url }
        if let index = index {
            tabBarView.didSelectIndex?(index)
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
