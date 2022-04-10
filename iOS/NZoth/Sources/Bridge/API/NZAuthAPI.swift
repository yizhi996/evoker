//
//  NZAuthAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZAuthAPI: String, NZBuiltInAPI {
   
    case openAuthorizationView
    case getSetting
    case getAuthorize
    case setAuthorize
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .openAuthorizationView:
                self.openAuthorizationView(args: args, bridge: bridge)
            case .getSetting:
                self.getSetting(args: args, bridge: bridge)
            case .getAuthorize:
                self.getAuthorize(args: args, bridge: bridge)
            case .setAuthorize:
                self.setAuthorize(args: args, bridge: bridge)
            }
        }
    }
            
    private func openAuthorizationView(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let viewController = appService.rootViewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: NZAuthorizationView.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let authView = NZAuthorizationView(params: params)
        let cover = NZCoverView(contentView: authView)
        authView.completionHandler = { authorized in
            NZEngine.shared.shouldInteractivePopGesture = true
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["authorized": authorized])
        }
        cover.show(to: viewController.view)
        NZEngine.shared.shouldInteractivePopGesture = false
    }
    
    private func getSetting(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        let (authSetting, error) = appService.storage.getAllAuthorization()
        if let error = error {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args, result: ["authSetting": authSetting])
        }
    }
    
    private func getAuthorize(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let scope: String
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let (authorized, error) = appService.storage.getAuthorization(params.scope)
        if let error = error {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args, result: ["status": authorized])
        }
    }
    
    private func setAuthorize(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let scope: String
            let authorized: Bool
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.storage.setAuthorization(params.scope, authorized: params.authorized) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
}
