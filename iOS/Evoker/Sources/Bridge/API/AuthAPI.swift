//
//  AuthAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum AuthAPI: String, CaseIterableAPI {
   
    case openAuthorizationView
    case getSetting
    case getAuthorize
    case setAuthorize
    case openSetting
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .openAuthorizationView:
                self.openAuthorizationView(appService: appService, bridge: bridge, args: args)
            case .getSetting:
                self.getSetting(appService: appService, bridge: bridge, args: args)
            case .getAuthorize:
                self.getAuthorize(appService: appService, bridge: bridge, args: args)
            case .setAuthorize:
                self.setAuthorize(appService: appService, bridge: bridge, args: args)
            case .openSetting:
                self.openSetting(appService: appService, bridge: bridge, args: args)
            }
        }
    }
            
    private func openAuthorizationView(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let viewController = appService.rootViewController else {
            let error = EKError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: AuthorizationView.Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let authView = AuthorizationView(params: params)
        let cover = CoverView(contentView: authView)
        authView.completionHandler = { authorized in
            Engine.shared.shouldInteractivePopGesture = true
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["authorized": authorized])
        }
        cover.show(to: viewController.view)
        Engine.shared.shouldInteractivePopGesture = false
    }
    
    private func getSetting(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        let (authSetting, error) = appService.storage.getAllAuthorization()
        if let error = error {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args, result: ["authSetting": authSetting])
        }
    }
    
    private func getAuthorize(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let scope: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
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
    
    private func setAuthorize(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let scope: String
            let authorized: Bool
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.storage.setAuthorization(params.scope, authorized: params.authorized) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func openSetting(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        let viewModel = SettingViewModel(appService: appService)
        viewModel.popViewControllerHandler = {
            let (authSetting, error) = appService.storage.getAllAuthorization()
            if let error = error {
                bridge.invokeCallbackFail(args: args, error: error)
            } else {
                bridge.invokeCallbackSuccess(args: args, result: ["authSetting": authSetting])
            }
        }
        appService.rootViewController?.pushViewController(viewModel.generateViewController(), animated: true)
    }
}
