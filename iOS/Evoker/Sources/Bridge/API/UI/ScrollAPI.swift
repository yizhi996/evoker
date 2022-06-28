//
//  ScrollAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum ScrollAPI: String, CaseIterableAPI {
   
    case operateScrollView
    case pageScrollTo
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .operateScrollView:
                operateScrollView(appService: appService, bridge: bridge, args: args)
            case .pageScrollTo:
                pageScrollTo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
        
    private func operateScrollView(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let parentId: String
            let scrollViewId: Int
            let bounces: Bool
            let showScrollbar: Bool
            let pagingEnabled: Bool
            let fastDeceleration: Bool
        }
        
        guard let webView = bridge.container as? WebView else {
            let error = EVError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let scrollView = webView.findWKChildScrollView(tongcengId: params.parentId) else {
            let error = EVError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        scrollView.bounces = params.bounces
        scrollView.showsVerticalScrollIndicator = params.showScrollbar
        scrollView.showsHorizontalScrollIndicator = params.showScrollbar
        scrollView.isPagingEnabled = params.pagingEnabled
        scrollView.decelerationRate = params.fastDeceleration ? .fast : .normal
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func pageScrollTo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let top: CGFloat
            let duration: TimeInterval
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webView = bridge.container as? WebView else {
            let error = EVError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIView.animate(withDuration: params.duration / 1000, delay: 0, options: .curveEaseInOut) {
            let top = min(max(0, params.top - webView.scrollView.frame.height),
                          max(0, webView.scrollView.contentSize.height - webView.scrollView.frame.height))
            webView.scrollView.contentOffset = CGPoint(x: 0, y: top)
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
