//
//  NZPullDownRefreshAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import MJRefresh

enum NZPullDownRefreshAPI: String, NZBuiltInAPI {
   
    case startPullDownRefresh
    case stopPullDownRefresh
    case addPullDownRefresh
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .startPullDownRefresh:
                startPullDownRefresh(args: args, bridge: bridge)
            case .stopPullDownRefresh:
                stopPullDownRefresh(args: args, bridge: bridge)
            case .addPullDownRefresh:
                addPullDownRefresh(args: args, bridge: bridge)
            }
        }
    }
    
    private func startPullDownRefresh(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let webView = (appService.currentPage as? NZWebPage)?.webView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webView.scrollView.mj_header?.beginRefreshing()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func stopPullDownRefresh(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let webView = (appService.currentPage as? NZWebPage)?.webView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webView.scrollView.mj_header?.endRefreshing()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func addPullDownRefresh(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let pageId = params["pageId"] as? Int else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("pageId"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webPage = appService.findWebPage(from: pageId) else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let normalHeader = MJRefreshNormalHeader(refreshingBlock: {
            bridge.subscribeHandler(method: NZWebPage.onPullDownRefreshSubscribeKey, data: ["pageId": pageId])
        })
        normalHeader.lastUpdatedTimeLabel?.isHidden = true
        normalHeader.stateLabel?.isHidden = true
        webPage.webView.scrollView.mj_header = normalHeader
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
