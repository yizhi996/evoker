//
//  NZNavigateAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZNavigateAPI: String, NZBuiltInAPI {
    
    case navigateToMiniProgram
    case exitMiniProgram
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .navigateToMiniProgram:
                navigateToMiniProgram(appService: appService, bridge: bridge, args: args)
            case .exitMiniProgram:
                exitMiniProgram(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func navigateToMiniProgram(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
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
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var envVersion: NZAppEnvVersion = .release
        if appService.envVersion == .develop || appService.envVersion == .trail {
            envVersion = NZAppEnvVersion(rawValue: params.envVersion.rawValue) ?? .release
        }
        
        NZEngine.shared.getAppInfo(appId: params.appId, envVersion: envVersion) { appInfo, error in
            if let error = error {
                bridge.invokeCallbackFail(args: args, error: error)
                return
            }
            let targetView = appService.rootViewController!.view!
            NZAlertView.show(title: "即将打开“\(appInfo!.appName)”小程序",
                             confirm: "允许",
                             mask: true,
                             to: targetView, cancelHandler: {
                let error = NZError.bridgeFailed(reason: .cancel)
                bridge.invokeCallbackFail(args: args, error: error)
            }) { _ in
                var options = NZAppLaunchOptions()
                options.path = params.path ?? ""
                options.envVersion = envVersion
                options.referrerInfo = NZAppEnterReferrerInfo(appId: appService.appId,
                                                              extraDataString: params.extraDataString)
                NZEngine.shared.openApp(appId: params.appId, launchOptions: options) { error in
                    if let error = error {
                        bridge.invokeCallbackFail(args: args, error: error)
                    } else {
                        bridge.invokeCallbackSuccess(args: args)
                    }
                }
            }
        }
    }
    
    private func exitMiniProgram(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        appService.exit()
        bridge.invokeCallbackSuccess(args: args)
    }
}
