//
//  ScreenAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum ScreenAPI: String, CaseIterableAPI {
    
    case getScreenBrightness
    case setScreenBrightness
    case setKeepScreenOn
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getScreenBrightness:
                getScreenBrightness(appService: appService, bridge: bridge, args: args)
            case .setScreenBrightness:
                setScreenBrightness(appService: appService, bridge: bridge, args: args)
            case .setKeepScreenOn:
                setKeepScreenOn(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getScreenBrightness(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        bridge.invokeCallbackSuccess(args: args, result: ["value": UIScreen.main.brightness])
    }
    
    private func setScreenBrightness(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let value: CGFloat
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIScreen.main.brightness = params.value
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setKeepScreenOn(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let keepScreenOn: Bool
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIApplication.shared.isIdleTimerDisabled = params.keepScreenOn
        
        appService.keepScreenOn = params.keepScreenOn
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
