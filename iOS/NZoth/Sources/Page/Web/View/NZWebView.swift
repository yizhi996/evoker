//
//  NZWebView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import WebKit

final public class NZWebView: WKWebView {
    
    public enum State {
        case none
        case loaded
        case terminate
        case fail
    }
    
    public weak var page: NZWebPage?
    
    public internal(set) var bridge: NZJSBridge!
    
    public internal(set) var state: State = .none {
        didSet {
            switch state {
            case .loaded:
                DispatchQueue.main.async {
                    self.pendingFunctions.forEach { _ = $0() }
                    self.pendingFunctions = []
                }
            default:
                pendingFunctions = []
            }
        }
    }
    
    public var adjustPosition = false
    
    private var pendingFunctions: [() -> Any?] = []

    private var didHandleWKContentGestrues = false
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        navigationDelegate = self
        uiDelegate = self
        backgroundColor = .white

        let scriptMessageHandler = NZScriptMessageHandler(delegate: self)
        configuration.userContentController.add(scriptMessageHandler, name: "invokeHandler")
        configuration.userContentController.add(scriptMessageHandler, name: "publishHandler")
        configuration.userContentController.add(scriptMessageHandler, name: "DOMContentLoaded")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        pendingFunctions = []
        NZLogger.debug("\(Self.self) deinit, appId: \(page?.appService?.appId ?? "preload")")
    }
    
    public func runAfterLoad(_ block: @escaping () -> Void) {
        if state == .none {
            pendingFunctions.append(block)
        } else if state == .loaded {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    @discardableResult
    public override func reload() -> WKNavigation? {
        reset()
        didHandleWKContentGestrues = false
        state = .none
        scrollView.mj_header = nil
        return super.reload()
    }
    
    private func reset() {
        guard let page = page else { return }
        page.appService?.modules.values.forEach { $0.willExitPage(page) }
    }

    public func recycle() {
        setTitle("NZoth - preload - webview")
        removeFromSuperview()
        reload()
    }
    
    public func setTitle(_ title: String) {
        runAfterLoad {
            self.evaluateJavaScript("document.title='\(title)'")
        }
    }
}

extension NZWebView {
    
    private func handleWKContentGestures() {
        let cls: AnyClass = NSClassFromString("WKScrollView")!
        if scrollView.isKind(of: cls) {
            let cls: AnyClass = NSClassFromString("WKContentView")!
            scrollView.subviews.first { subview -> Bool in
                return subview.isKind(of: cls)
            }?.gestureRecognizers?.forEach { gesture in
                let cls: AnyClass = NSClassFromString("UIVariableDelayLoupeGesture")!
                if gesture.isKind(of: cls) {
                    gesture.delegate = self
                }
                gesture.cancelsTouchesInView = false
                gesture.delaysTouchesBegan = false
                gesture.delaysTouchesEnded = false
                didHandleWKContentGestrues = true
            }
        }
    }
    
    private func findUserSelectRegionView(view: UIView) -> UIView? {
        let cls: AnyClass = NSClassFromString("WKCompositingView")!
        if view.isKind(of: cls) && view.description.contains("__nz_selectable_region") {
            return view
        }
        var selectRegion: UIView?
        for subview in view.subviews {
            if let hit = findUserSelectRegionView(view: subview) {
                selectRegion = hit
                break
            }
        }
        return selectRegion
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if !didHandleWKContentGestrues {
            handleWKContentGestures()
        }
        
        let cls: AnyClass = NSClassFromString("WKChildScrollView")!
        if let childScrollView = hitView, childScrollView.isKind(of: cls) {
            var hitView: UIView?
            for subview in childScrollView.subviews.reversed() {
                let point = subview.convert(point, from: self)
                if let hit = subview.hitTest(point, with: event) {
                    hitView = hit
                    break
                }
            }

            if hitView != nil {
                return hitView
            }
        }
        return hitView
    }
}

//MARK: WKScriptMessageHandler
extension NZWebView: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        switch message.name {
        case "invokeHandler":
            guard let event = body["event"] as? String,
                  let params = body["params"] as? String,
                  let cbId = body["callbackId"] as? Int else { return }
            let args = NZJSBridge.InvokeArgs(eventName: event, paramsString: params, callbackId: cbId)
            bridge.onInvoke(args)
        case "publishHandler":
            guard let event = body["event"] as? String,
                  let params = body["params"] as? String,
                  let webViewId = body["webViewId"] as? Int else { return }
            let args = NZJSBridge.PublishArgs(eventName: event, paramsString: params, webViewId: webViewId)
            bridge.onPublish(args)
        case "DOMContentLoaded":
            state = .loaded
        default:
            break
        }
    }
}

//MARK: WKNavigationDelegate
extension NZWebView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NZLogger.error("WKWebView error: \(error)")
        state = .fail
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NZLogger.error("WKWebView error: \(error)")
        state = .fail
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        state = .terminate
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

//MARK: WKUIDelegate
extension NZWebView: WKUIDelegate {
    
}

//MARK: UIGestureRecognizerDelegate
extension NZWebView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }

}

//MARK: NZJSContainer
extension NZWebView: NZJSContainer {
    
    public func evaluateScript(_ script: String) {
        runAfterLoad {
            self.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

//MARK: NZSubscribeKey
extension NZWebView {
    
    public static let onLoadSubscribeKey = NZSubscribeKey("WEBVIEW_ON_LOAD")
}
