//
//  NZLifeCycleAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZLifeCycleAPI: String, NZBuiltInAPI {
    
    case pageLifeRequired

    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        switch self {
        case .pageLifeRequired:
            pageLifeRequired(args: args, bridge: bridge)
        }
    }

    private func pageLifeRequired(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let pageId: Int
            let onPageScroll: Bool?
        }
        
        guard let appService = bridge.appService else { return }
        
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
        
        webPage.isSubscribeOnPageScroll = params.onPageScroll == true
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
