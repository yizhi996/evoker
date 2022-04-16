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
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .startPullDownRefresh:
                startPullDownRefresh(appService: appService, bridge: bridge, args: args)
            case .stopPullDownRefresh:
                stopPullDownRefresh(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func startPullDownRefresh(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let webView = (appService.currentPage as? NZWebPage)?.webView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webView.scrollView.mj_header?.beginRefreshing()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func stopPullDownRefresh(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let webView = (appService.currentPage as? NZWebPage)?.webView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webView.scrollView.mj_header?.endRefreshing()
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
