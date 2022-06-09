//
//  NZOpenAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZOpenAPI: String, NZBuiltInAPI {
    
    case login
    case checkSession
    case getUserInfo
    case getUserProfile

    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .login:
                self.login(appService: appService, bridge: bridge, args: args)
            case .checkSession:
                self.checkSession(appService: appService, bridge: bridge, args: args)
            case .getUserInfo:
                self.getUserInfo(appService: appService, bridge: bridge, args: args)
            case .getUserProfile:
                self.getUserProfile(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func login(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        if let hook = NZEngineConfig.shared.hooks.openAPI.login {
            hook(appService, bridge, args)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func checkSession(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        if let hook = NZEngineConfig.shared.hooks.openAPI.checkSession {
            hook(appService, bridge, args)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getUserInfo(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        if let hook = NZEngineConfig.shared.hooks.openAPI.getUserInfo {
            hook(appService, bridge, args)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getUserProfile(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        if let hook = NZEngineConfig.shared.hooks.openAPI.getUserProfile {
            hook(appService, bridge, args)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
}
