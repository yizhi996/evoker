//
//  PullDownRefreshAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import MJRefresh

enum PullDownRefreshAPI: String, CaseIterableAPI {
   
    case startPullDownRefresh
    case stopPullDownRefresh
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .startPullDownRefresh:
                startPullDownRefresh(appService: appService, bridge: bridge, args: args)
            case .stopPullDownRefresh:
                stopPullDownRefresh(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func startPullDownRefresh(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = (appService.currentPage as? WebPage)?.webView else {
            let error = EVError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webView.scrollView.mj_header?.beginRefreshing()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func stopPullDownRefresh(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = (appService.currentPage as? WebPage)?.webView else {
            let error = EVError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webView.scrollView.mj_header?.endRefreshing()
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
