//
//  NavigateAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NavigateAPI: String, CaseIterableAPI {
    
    case navigateToMiniProgram
    case exitMiniProgram
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .navigateToMiniProgram:
                navigateToMiniProgram(appService: appService, bridge: bridge, args: args)
            case .exitMiniProgram:
                exitMiniProgram(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func navigateToMiniProgram(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let appId: String
            let path: String?
            let extraDataString: String?
            let envVersion: EnvVersion
        }
        
        enum EnvVersion: String, Decodable {
            case develop
            case trial
            case release
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var envVersion: AppEnvVersion = .release
        if appService.envVersion == .develop || appService.envVersion == .trail {
            envVersion = AppEnvVersion(rawValue: params.envVersion.rawValue) ?? .release
        }
        
        Engine.shared.getAppInfo(appId: params.appId, envVersion: envVersion) { appInfo, error in
            if let error = error {
                bridge.invokeCallbackFail(args: args, error: error)
                return
            }
            let targetView = appService.rootViewController!.view!
            Alert.show(title: "即将打开“\(appInfo!.appName)”小程序",
                             confirm: "允许",
                             mask: true,
                             to: targetView, cancelHandler: {
                let error = EKError.bridgeFailed(reason: .cancel)
                bridge.invokeCallbackFail(args: args, error: error)
            }) { _ in
                var options = AppLaunchOptions()
                options.path = params.path ?? ""
                options.envVersion = envVersion
                options.referrerInfo = AppEnterReferrerInfo(appId: appService.appId,
                                                              extraDataString: params.extraDataString)
                Engine.shared.openApp(appId: params.appId, launchOptions: options) { error in
                    if let error = error {
                        bridge.invokeCallbackFail(args: args, error: error)
                    } else {
                        bridge.invokeCallbackSuccess(args: args)
                    }
                }
            }
        }
    }
    
    private func exitMiniProgram(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        appService.exit()
        bridge.invokeCallbackSuccess(args: args)
    }
}
