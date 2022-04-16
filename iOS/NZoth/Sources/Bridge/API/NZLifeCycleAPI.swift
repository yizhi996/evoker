//
//  NZLifeCycleAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import MJRefresh

enum NZLifeCycleAPI: String, NZBuiltInAPI {
    
    case pageEffect

    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .pageEffect:
                self.pageEffect(appService: appService, bridge: bridge, args: args)
            }
        }
    }

    private func pageEffect(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let pageId: Int
            let hooks: [String: Bool]
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webPage = appService.findWebPage(from: params.pageId) else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webPage.isSubscribeOnPageScroll = params.hooks["onPageScroll"] ?? false
       
        if let x = params.hooks["onPullDownRefresh"], x == true {
            let normalHeader = MJRefreshNormalHeader(refreshingBlock: {
                bridge.subscribeHandler(method: NZWebPage.onPullDownRefreshSubscribeKey,
                                        data: ["pageId": params.pageId])
            })
            normalHeader.lastUpdatedTimeLabel?.isHidden = true
            normalHeader.stateLabel?.isHidden = true
            webPage.webView.scrollView.mj_header = normalHeader
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
