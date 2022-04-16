//
//  NZVibrateAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AudioToolbox

enum NZVibrateAPI: String, NZBuiltInAPI {
    
    case vibrateShort
    case vibrateLong
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .vibrateShort:
                vibrateShort(appService: appService, bridge: bridge, args: args)
            case .vibrateLong:
                vibrateLong(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func vibrateShort(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let type: `Type`
        }
        
        enum `Type`: String, Decodable {
            case heavy
            case medium
            case light
            
            func toNatively() -> UIImpactFeedbackGenerator.FeedbackStyle {
                switch self {
                case .heavy:
                    return .heavy
                case .medium:
                    return .medium
                case .light:
                    return .light
                }
            }
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: params.type.toNatively())
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func vibrateLong(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        bridge.invokeCallbackSuccess(args: args)
    }
}
