//
//  NZBrowserViewController.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import WebKit

open class NZBrowserViewController: NZPageViewController {
    
    public var webView: WKWebView!
    
    let progressView = UIProgressView()
    
    public var _page: NZBrowserPage {
        return page as! NZBrowserPage
    }
    
    private var closeBarButtonItem: UIBarButtonItem!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBarButtonItem = UIBarButtonItem(image: UIImage(builtIn: "close-icon"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(onClose))
        
        let webConfig = WKWebViewConfiguration()
        _page.cookies.forEach { cookie in
            webConfig.websiteDataStore.httpCookieStore.setCookie(cookie) {
                print("OK")
            }
        }

        webView = WKWebView(frame: view.bounds, configuration: webConfig)
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        if #available(iOS 13.0, *) {
            webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = true
        }
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        if let url = _page.url {
            webView.load(URLRequest(url: url))
        }
        view.addSubview(webView)
        
        webView.autoPinEdgesToSuperviewEdges()
        
        view.addSubview(progressView)
        progressView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        progressView.autoSetDimension(.height, toSize: 2.0)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func onBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            super.onBack()
        }
    }
    
    @objc func onClose() {
        navigationController?.popViewController(animated: true)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.progress = progress
            progressView.isHidden = progress == 1.0
        } else if keyPath == "title" {
            navigationItem.title = webView.title
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

extension NZBrowserViewController: WKNavigationDelegate {
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.canGoBack {
            if navigationItem.leftBarButtonItems?.contains(closeBarButtonItem) == false {
                navigationItem.leftBarButtonItems?.append(closeBarButtonItem)
            }
        } else {
            if navigationItem.leftBarButtonItems?.contains(closeBarButtonItem) == true {
                navigationItem.leftBarButtonItems?.removeLast()
            }
        }
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
