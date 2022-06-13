//
//  NZScreenAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZScreenAPI: String, NZBuiltInAPI {
    
    case getScreenBrightness
    case setScreenBrightness
    case setKeepScreenOn
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
    
    private func getScreenBrightness(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        bridge.invokeCallbackSuccess(args: args, result: ["value": UIScreen.main.brightness])
    }
    
    private func setScreenBrightness(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let value: CGFloat
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIScreen.main.brightness = params.value
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setKeepScreenOn(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let keepScreenOn: Bool
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIApplication.shared.isIdleTimerDisabled = params.keepScreenOn
        
        appService.keepScreenOn = params.keepScreenOn
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
