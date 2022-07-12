//
//  RouteAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import Telegraph

enum RouteAPI: String, CaseIterableAPI {
   
    case navigateTo
    case navigateBack
    case redirectTo
    case switchTab
    case reLaunch
    case openBrowser
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .navigateTo:
                navigateTo(appService: appService, bridge: bridge, args: args)
            case .navigateBack:
                navigateBack(appService: appService, bridge: bridge, args: args)
            case .redirectTo:
                redirectTo(appService: appService, bridge: bridge, args: args)
            case .switchTab:
                switchTab(appService: appService, bridge: bridge, args: args)
            case .reLaunch:
                reLaunch(appService: appService, bridge: bridge, args: args)
            case .openBrowser:
                openBrowser(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func navigateTo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.createWebPage(url: params.url) else {
            let error = EKError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.push(page, animated: true, completedHandler: {
            bridge.invokeCallbackSuccess(args: args)
        })
    }
    
    private func navigateBack(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
       
        struct Params: Decodable {
            let delta: Int
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.pop(delta: params.delta)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func redirectTo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.redirectTo(params.url) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func switchTab(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.switchTo(url: params.url)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func reLaunch(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.reLaunch(url: params.url) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func openBrowser(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {        
        guard let params = args.paramsString.toDict() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
            
        guard let url = params["url"] as? String, !url.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("url"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.createBrowserPage(url: url) else {
            let error = EKError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.push(page)
        bridge.invokeCallbackSuccess(args: args)
    }
}
