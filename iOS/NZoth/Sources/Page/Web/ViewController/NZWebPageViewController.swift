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
        
        if webPage.state == .loaded {
            webPage.show(publish: !isFirstLoad)
        }
        
        isFirstLoad = false
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        webPage.hide()
        if isMovingFromParent {
            if !page.isTabBarPage {
                webPage.unload()
            }
        }
        super.viewDidDisappear(animated)
    }
    
    open override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            if !page.isTabBarPage {
                webPage.unload()
            }
        }
        super.didMove(toParent: parent)
    }
    
    deinit {
        webPage.unload()
    }
    
    @objc open func scrollToTop() {
        let offset = CGPoint(x: 0, y: -webView.scrollView.adjustedContentInset.top)
        webView.scrollView.setContentOffset(offset, animated: true)
    }
    
}

extension NZWebPageViewController: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll.invoke { [unowned self] in
            if self.webPage.isSubscribeOnPageScroll {
                self.page.appService?.bridge.subscribeHandler(method: NZWebPage.onPageScrollSubscribeKey,
                                                              data: ["pageId": self.page.pageId,
                                                                     "scrollTop": scrollView.contentOffset.y])
            }
            self.page.appService?.modules.values.forEach { $0.onPageScroll(self.page) }
        }
    }
}
