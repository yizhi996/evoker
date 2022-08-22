//
//  AuthAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public enum FetchShareAppMessageContentFrom: String {
    case menu
    
    case button
}

enum ShareAPI: String, CaseIterableAPI {
   
    case showShareMenu
    
    case hideShareMenu
    
    case shareAppMessage
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        switch self {
        case .showShareMenu:
            showShareMenu(appService: appService, bridge: bridge, args: args)
        case .hideShareMenu:
            hideShareMenu(appService: appService, bridge: bridge, args: args)
        case .shareAppMessage:
            shareAppMessage(appService: appService, bridge: bridge, args: args)
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
    
    private func shareAppMessage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        var target: [String: Any]? = nil
        if let params = args.paramsString.toDict() {
            target = params["target"] as? [String : Any]
        }
        appService.fetchShareAppMessageContent(from: .button, target: target)
        bridge.invokeCallbackSuccess(args: args)
    }
}
