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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .startPullDownRefresh:
                startPullDownRefresh(args: args, bridge: bridge)
            case .stopPullDownRefresh:
                stopPullDownRefresh(args: args, bridge: bridge)
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
    
}
