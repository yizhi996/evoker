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

    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .login:
                self.login(args: args, bridge: bridge)
            case .checkSession:
                self.checkSession(args: args, bridge: bridge)
            case .getUserInfo:
                self.getUserInfo(args: args, bridge: bridge)
            case .getUserProfile:
                self.getUserProfile(args: args, bridge: bridge)
            }
        }
    }
    
    private func login(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        if let hook = NZEngineHooks.shared.openAPI.login {
            hook(args, bridge)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func checkSession(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        if let hook = NZEngineHooks.shared.openAPI.checkSession {
            hook(args, bridge)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getUserInfo(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        if let hook = NZEngineHooks.shared.openAPI.getUserInfo {
            hook(args, bridge)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getUserProfile(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        if let hook = NZEngineHooks.shared.openAPI.getUserProfile {
            hook(args, bridge)
        } else {
            let error = NZError.bridgeFailed(reason: .apiHookNotImplemented)
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
}
