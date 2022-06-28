//
//  OpenAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum OpenAPI: String, CaseIterableAPI {
    
    case login
    case checkSession
    case getUserInfo
    case getUserProfile

    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
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
    
    private func login(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        if let hook = Engine.shared.config.hooks.openAPI.login {
            hook(appService, bridge, args)
        } else {
            let error = EVError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func checkSession(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        if let hook = Engine.shared.config.hooks.openAPI.checkSession {
            hook(appService, bridge, args)
        } else {
            let error = EVError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getUserInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        if let hook = Engine.shared.config.hooks.openAPI.getUserInfo {
            hook(appService, bridge, args)
        } else {
            let error = EVError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getUserProfile(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        if let hook = Engine.shared.config.hooks.openAPI.getUserProfile {
            hook(appService, bridge, args)
        } else {
            let error = EVError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
}
