//
//  AuthAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum ShareAPI: String, CaseIterableAPI {
   
    case showShareMenu
    
    case hideShareMenu
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        switch self {
        case .showShareMenu:
            showShareMenu(appService: appService, bridge: bridge, args: args)
        case .hideShareMenu:
            hideShareMenu(appService: appService, bridge: bridge, args: args)
        }
    }
        
    private func showShareMenu(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let route: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.findWebPage(from: params.route) else {
            let error = EKError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        page.shareEnable = true
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideShareMenu(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let route: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.findWebPage(from: params.route) else {
            let error = EKError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        page.shareEnable = false
        bridge.invokeCallbackSuccess(args: args)
    }
}
