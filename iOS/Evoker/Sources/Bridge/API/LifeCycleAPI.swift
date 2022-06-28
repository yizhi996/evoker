//
//  LifeCycleAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import MJRefresh

enum LifeCycleAPI: String, CaseIterableAPI {
    
    case pageEffect

    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .pageEffect:
                self.pageEffect(appService: appService, bridge: bridge, args: args)
            }
        }
    }

    private func pageEffect(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let pageId: Int
            let hooks: [String: Bool]
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webPage = appService.findWebPage(from: params.pageId) else {
            let error = EVError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webPage.isSubscribeOnPageScroll = params.hooks["onPageScroll"] ?? false
       
        if let x = params.hooks["onPullDownRefresh"], x == true {
            let normalHeader = MJRefreshNormalHeader(refreshingBlock: {
                bridge.subscribeHandler(method: WebPage.onPullDownRefreshSubscribeKey,
                                        data: ["pageId": params.pageId])
            })
            normalHeader.lastUpdatedTimeLabel?.isHidden = true
            normalHeader.stateLabel?.isHidden = true
            webPage.webView.scrollView.mj_header = normalHeader
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
