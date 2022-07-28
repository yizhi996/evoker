//
//  WebPage.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import WebKit
import MJRefresh
import Alamofire

open class WebPage: Page {
        
    public enum State: Int {
        case none
        case loaded
        case unloaded
    }
    
    public let pageId: Int
    
    public let url: String
    
    public weak var appService: AppService?
    
    public weak var viewController: PageViewController?
    
    public var style: AppConfig.Style?
    
    public var isTabBarPage = false
    
    public var isShowTabBar = true
    
    public var tabIndex: UInt8 = 0
    
    public var isVisible = false
    
    public internal(set) var state: State = .none
    
    public internal(set) var route: String = ""
    
    var forceRotateScreen = false
    
    var isFullscreenVideoPlayer = false
    
    var isSubscribeOnPageScroll = false
    
    var isFromTabItemTap = false
    
    public lazy var webView: WebView = {
        assert(appService != nil, "AppService 不能为空")
        let appService = appService!
        let webView: WebView
        if appService.webViewPool.count == 0 {
            webView = Engine.shared.webViewPool.idle()
            appService.loadAppCSS(to: webView)
            appService.preloadWebView()
        } else {
            webView = appService.idleWebView()
        }
        webView.bridge = JSBridge(appService: appService, container: webView)
        webView.page = self
        webView.backgroundColor = backgroundColor
        webView.runAfterLoad { [unowned self] in
            self.mount()
        }
        return webView
    }()
    
    public var fullscreen: Bool {
        return false
    }
    
    public func setTitle(_ title: String) {
        style?.navigationBarTitleText = title
        let viewController = (viewController as? WebPageViewController)
        viewController?.navigationBar.setTitle(title)
    }
    
    public var customTitleType: String? {
        return nil
    }
    
    public var pageOrientation: AppConfig.Style.PageOrientation {
        if forceRotateScreen {
            return .auto
        }
        return .portrait
    }
    
    public required init(appService: AppService, url: String) {
        self.appService = appService
        self.url = url
        pageId = appService.genPageId()
        
        if let url = URL(string: url) {
            route = url.path
        } else {
            route = url
        }
        
        if let pageConfig = appService.config.pages.first(where: { $0.path == route }) {
            style = pageConfig.style
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterFullscreenVideoPlayer(_:)),
                                               name: VideoPlayerView.willEnterFullscreenVideoPlayer,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willQuitFullscreenVideoPlayer(_:)),
                                               name: VideoPlayerView.willQuitFullscreenVideoPlayer,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Logger.debug("\(Self.self) deinit, appId: \(appService?.appId ?? "preload")")
    }
    
    open func reload() {
        webView.reload()
        if let appService = appService {
            appService.loadAppCSS(to: webView)
        }
        webView.runAfterLoad { [unowned self] in
            self.mount()
        }
    }
    
    open func generateViewController() -> PageViewController {
        return WebPageViewController(page: self)
    }
    
    func mount() {
        guard let appService = appService else { return }
        
        let script = """
        window.webViewId = \(pageId);
        document.title = '\(appService.appInfo.appName) - \(route)';
        \(appService.generateConfigScript())
        """
        webView.evaluateJavaScript(script)
        
        var tabText = ""
        if isFromTabItemTap {
            tabText = appService.uiControl.tabBarView.tabBarItems[Int(tabIndex)].title(for: .normal) ?? ""
        }
        
        appService.bridge.subscribeHandler(method:WebPage.beginMountSubscribeKey, data: ["pageId": pageId,
                                                                                         "tabIndex": tabIndex,
                                                                                         "fromTabItemTap": isFromTabItemTap,
                                                                                         "tabText": tabText,
                                                                                         "path": url])
        Engine.shared.config.hooks.pageLifeCycle.onLoad?(self)
        appService.modules.values.forEach { $0.onLoad(self) }
        
        Engine.shared.config.hooks.pageLifeCycle.onShow?(self)
        appService.modules.values.forEach { $0.onShow(self) }
    }

    func publishOnShow() {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method:WebPage.onShowSubscribeKey, data: ["pageId": pageId])
        Engine.shared.config.hooks.pageLifeCycle.onShow?(self)
        appService.modules.values.forEach { $0.onShow(self) }
    }
    
    func publishOnReady() {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method:WebPage.onReadySubscribeKey, data: ["pageId": pageId])
        Engine.shared.config.hooks.pageLifeCycle.onReady?(self)
        appService.modules.values.forEach { $0.onReady(self) }
    }
    
    func publishOnHide() {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method:WebPage.onHideSubscribeKey, data: ["pageId": pageId])
        Engine.shared.config.hooks.pageLifeCycle.onHide?(self)
        appService.modules.values.forEach { $0.onHide(self) }
    }
    
    func publishOnUnload(recycle: Bool = false) {
        guard let appService = appService else { return }
        if state == .loaded {
            Logger.debug("\(appService.appId) - \(route) onUnload")
            
            state = .unloaded
            appService.bridge.subscribeHandler(method: WebPage.onUnloadSubscribeKey, data: ["pageId": pageId])
            Engine.shared.config.hooks.pageLifeCycle.onUnload?(self)
            appService.modules.values.forEach { $0.onUnload(self) }
            
            if recycle {
                appService.recycle(webView: webView)
            }
        }
        
        if let index = appService.pages.firstIndex(where: { $0.pageId == pageId }) {
            appService.pages.remove(at: index)
        }
    }
        
}

extension WebPage {
    
    @objc func willEnterFullscreenVideoPlayer(_ notify: Notification) {
        isFullscreenVideoPlayer = true
        let isShowNavigationBar = navigationStyle == .default
        if isShowNavigationBar {
            viewController?.navigationBar.isHidden = true
        }
        if isTabBarPage {
            appService?.uiControl.tabBarView.isHidden = true
        }
        
        guard let view = viewController?.view else { return }
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        viewController?.setNeedsUpdateOfHomeIndicatorAutoHidden()
        appService?.uiControl.hideCapsule()
    }
    
    @objc func willQuitFullscreenVideoPlayer(_ notify: Notification) {
        isFullscreenVideoPlayer = false
        let isShowNavigationBar = navigationStyle == .default
        if isShowNavigationBar {
            viewController?.navigationBar.isHidden = false
        }
        if isTabBarPage {
            appService?.uiControl.tabBarView.isHidden = false
        }
        
        guard let view = viewController?.view else { return }
        
        let navigationBarHeight = isShowNavigationBar ? Constant.statusBarHeight + Constant.navigationBarHeight : 0
        let tabBarHeight = isTabBarPage ? Constant.tabBarHeight : 0
        
        webView.frame = CGRect(x: 0,
                               y: navigationBarHeight,
                               width: view.frame.width,
                               height: view.frame.height - tabBarHeight - navigationBarHeight)
        viewController?.setNeedsUpdateOfHomeIndicatorAutoHidden()
        appService?.uiControl.showCapsule()
    }
}

//MARK: SubscribeKey
extension WebPage {
    
    public static let beginMountSubscribeKey = SubscribeKey("PAGE_BEGIN_MOUNT")
    
    public static let onLoadSubscribeKey = SubscribeKey("PAGE_ON_LOAD")

    public static let onShowSubscribeKey = SubscribeKey("PAGE_ON_SHOW")
    
    public static let onReadySubscribeKey = SubscribeKey("PAGE_ON_READY")
    
    public static let onHideSubscribeKey = SubscribeKey("PAGE_ON_HIDE")
    
    public static let onUnloadSubscribeKey = SubscribeKey("PAGE_ON_UNLOAD")
    
    public static let onPageScrollSubscribeKey = SubscribeKey("PAGE_ON_SCROLL")
    
    public static let onPullDownRefreshSubscribeKey = SubscribeKey("PAGE_ON_PULL_DOWN_REFRESH")
    
    public static let onTabItemTapSubscribeKey = SubscribeKey("PAGE_ON_TAB_ITEM_TAP")

}
