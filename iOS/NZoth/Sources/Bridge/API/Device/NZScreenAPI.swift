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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
        switch self {
            case .getScreenBrightness:
                getScreenBrightness(args: args, bridge: bridge)
            case .setScreenBrightness:
                setScreenBrightness(args: args, bridge: bridge)
            }
        }
    }
    
    private func getScreenBrightness(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        bridge.invokeCallbackSuccess(args: args, result: ["value": UIScreen.main.brightness])
    }
    
    private func setScreenBrightness(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
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
}
