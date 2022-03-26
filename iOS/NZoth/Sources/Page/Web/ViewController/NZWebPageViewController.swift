//
//  NZWebPageViewController.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZWebPageViewController: NZPageViewController {
    
    public var webPage: NZWebPage {
        return page as! NZWebPage
    }
    
    public var webView: NZWebView {
        return webPage.webView
    }
    
    open override var shouldAutorotate: Bool {
        return webPage.pageOrientation == .auto
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscape, .portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return webPage.isFullscreenVideoPlayer
    }
    
    private let onScroll = Throttler(seconds: 1 / 30, qos: .userInteractive)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        webPage.state = .loaded
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInset = .zero
        webView.scrollView.delegate = self
        let navigationBarHeight = page.navigationStyle == .default ? Constant.topHeight : 0
        let tabBarHeight = page.isTabBarPage ? Constant.tabBarHeight : 0
        webView.frame = CGRect(x: 0,
                               y: navigationBarHeight,
                               width: view.frame.width,
                               height: view.frame.height - tabBarHeight - navigationBarHeight)
        view.insertSubview(webView, at: 0)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if webView.state == .terminate {
            webPage.reload()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstLoad && webPage.state == .loaded {
            webPage.appService?.bridge.subscribeHandler(method: NZWebPage.onShowSubscribeKey, data: ["pageId": page.pageId])
        }
        
        isFirstLoad = false
        
        guard let inputModule: NZInputModule = webPage.appService?.getModule(),
              let needFocusInput = inputModule.last(pageId: page.pageId, where: { $0.needFocus }) else { return }
        needFocusInput.startEdit()
        inputModule.allInputs(pageId: page.pageId).forEach { $0.needFocus = false }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParent {
            if !page.isTabBarPage {
                webPage.onUnload()
            }
        }
        super.viewDidDisappear(animated)
    }
    
    open override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            if !page.isTabBarPage {
                webPage.onUnload()
            }
        }
        super.didMove(toParent: parent)
    }
    
    deinit {
        webPage.onUnload()
    }
    
    @objc open func scrollToTop() {
        let offset = CGPoint(x: 0, y: -webView.scrollView.adjustedContentInset.top)
        webView.scrollView.setContentOffset(offset, animated: true)
    }
    
}

extension NZWebPageViewController: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll.invoke { [unowned self] in
            guard let inputModule: NZInputModule = self.webPage.appService?.getModule(),
                  let needResignFirstInput = inputModule.first(pageId: self.webPage.pageId, where: { $0.isFirstResponder }) else { return }
            needResignFirstInput.endEdit()
        }
    }
}
