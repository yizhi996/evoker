//
//  NZRouteAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import Telegraph

enum NZRouteAPI: String, NZBuiltInAPI {
   
    case navigateTo
    case navigateBack
    case redirectTo
    case switchTab
    case reLaunch
    case openBrowser
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
    
    private func navigateTo(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.createWebPage(url: params.url) else {
            let error = NZError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.push(page, animated: true, completedHandler: {
            bridge.invokeCallbackSuccess(args: args)
        })
    }
    
    private func navigateBack(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
       
        struct Params: Decodable {
            let delta: Int
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.pop(delta: params.delta)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func redirectTo(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let (path, _) = params.url.decodeURL()
        
        let isTab = appService.config.tabBar?.list.contains(where: { $0.path == path })
        if isTab == true {
            bridge.invokeCallbackSuccess(args: args)
            return
        }
        
        if let error = appService.redirectTo(params.url) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func switchTab(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.switchTo(url: params.url)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func reLaunch(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.reLaunch(url: params.url) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func openBrowser(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
            
        guard let url = params["url"] as? String, !url.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("url"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.createBrowserPage(url: url) else {
            let error = NZError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        appService.push(page)
        bridge.invokeCallbackSuccess(args: args)
    }
}
