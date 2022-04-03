//
//  NZWebPage.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import WebKit
import MJRefresh
import Alamofire

open class NZWebPage: NZPage {
        
    public enum State: Int {
        case none
        case loaded
        case unloaded
    }
    
    public let pageId: Int
    
    public let url: String
    
    public weak var appService: NZAppService?
    
    public weak var viewController: NZPageViewController?
    
    public var style: NZPageStyle?
    
    public var isTabBarPage = false
    
    public var isShowTabBar = true
    
    public var isVisible = false
    
    public internal(set) var state: State = .none
    
    public internal(set) var route: String = ""
    
    var forceRotateScreen = false
    
    var isFullscreenVideoPlayer = false
    
    var isSubscribeOnPageScroll = false
    
    public lazy var webView: NZWebView = {
        assert(appService != nil, "AppService 不能为空")
        let appService = appService!
        let webView: NZWebView
        if appService.webViewPool.count == 0 {
            webView = NZEngine.shared.webViewPool.idle()
            appService.loadAppCSS(to: webView)
            appService.preloadWebView()
        } else {
            webView = appService.idleWebView()
        }
        webView.bridge = NZJSBridge(appService: appService, container: webView)
        webView.page = self
        webView.backgroundColor = backgroundColor
        webView.runAfterLoad { [unowned self] in
            self.setPageInfo()
            self.mount()
        }
        return webView
    }()
    
    public var fullscreen: Bool {
        return false
    }
    
    public func setTitle(_ title: String) {
        style?.navigationBarTitleText = title
        let viewController = (viewController as? NZWebPageViewController)
        viewController?.navigationBar.setTitle(title)
    }
    
    public var customTitleType: String? {
        return nil
    }
    
    public var pageOrientation: NZPageStyle.PageOrientation {
        if forceRotateScreen {
            return .auto
        }
        return .portrait
    }
    
    public required init(appService: NZAppService, url: String) {
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
                                               name: NZVideoPlayerView.willEnterFullscreenVideoPlayer,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willQuitFullscreenVideoPlayer(_:)),
                                               name: NZVideoPlayerView.willQuitFullscreenVideoPlayer,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NZLogger.debug("\(Self.self) deinit, appId: \(appService?.appId ?? "preload")")
    }
    
    open func reload() {
        webView.reload()
        if let appService = appService {
            appService.loadAppCSS(to: webView)
        }
        webView.runAfterLoad { [unowned self] in
            self.setPageInfo()
            self.mount()
        }
    }
    
    open func generateViewController() -> NZPageViewController {
        return NZWebPageViewController(page: self)
    }
    
    func setPageInfo() {
        guard let appService = appService else { return }
        
        let js = "window.webViewId=\(pageId);document.title='\(appService.appId) - \(route)';"
        webView.evaluateJavaScript(js)
    }
    
    func mount() {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method:NZWebPage.beginMountSubscribeKey, data: ["pageId": pageId,
                                                                                           "path": url])
        appService.modules.values.forEach { $0.onLoad(self) }
    }
    
    func show(publish: Bool) {
        guard let appService = appService else { return }
        if publish {
            appService.bridge.subscribeHandler(method:NZWebPage.onShowSubscribeKey, data: ["pageId": pageId])
        }
        appService.modules.values.forEach { $0.onShow(self) }
    }
    
    func hide() {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method:NZWebPage.onHideSubscribeKey, data: ["pageId": pageId])
        appService.modules.values.forEach { $0.onHide(self) }
    }
    
    func unload() {
        guard let appService = appService else { return }
        
        if state == .loaded {
            NZLogger.debug("\(appService.appId) - \(route) onUnload")
            
            state = .unloaded
            appService.bridge.subscribeHandler(method: NZWebPage.onUnloadSubscribeKey, data: ["pageId": pageId])
            appService.recycle(webView: webView)
            appService.modules.values.forEach { $0.onUnload(self) }
        }
        
        if let index = appService.pages.firstIndex(where: { $0.pageId == pageId }) {
            appService.pages.remove(at: index)
        }
    }
}

extension NZWebPage {
    
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
    }
}

//MARK: NZSubscribeKey
extension NZWebPage {
    
    public static let beginMountSubscribeKey = NZSubscribeKey("PAGE_BEGIN_MOUNT")
    
    public static let onLoadSubscribeKey = NZSubscribeKey("PAGE_ON_LOAD")

    public static let onShowSubscribeKey = NZSubscribeKey("PAGE_ON_SHOW")
    
    public static let onHideSubscribeKey = NZSubscribeKey("PAGE_ON_HIDE")
    
    public static let onUnloadSubscribeKey = NZSubscribeKey("PAGE_ON_UNLOAD")
    
    public static let onPageScrollSubscribeKey = NZSubscribeKey("PAGE_ON_SCROLL")
    
    public static let onPullDownRefreshSubscribeKey = NZSubscribeKey("PAGE_ON_PULL_DOWN_REFRESH")

}
