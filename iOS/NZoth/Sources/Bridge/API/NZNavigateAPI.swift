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
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .navigateToMiniProgram:
                navigateToMiniProgram(appService: appService, bridge: bridge, args: args)
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
        var options = NZAppLaunchOptions()
        options.path = params.path ?? ""
        options.envVersion = envVersion
        options.referrerInfo = NZAppLaunchOptions.ReferrerInfo(appId: appService.appId,
                                                               extraDataString: params.extraDataString)
        NZEngine.shared.openApp(appId: params.appId, launchOptions: options, completionHandler: nil)
        bridge.invokeCallbackSuccess(args: args)
    }
}
