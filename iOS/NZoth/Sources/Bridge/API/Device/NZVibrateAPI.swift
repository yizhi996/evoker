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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
        switch self {
            case .vibrateShort:
                vibrateShort(args: args, bridge: bridge)
            case .vibrateLong:
                vibrateLong(args: args, bridge: bridge)
            }
        }
    }
    
    private func vibrateShort(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
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

        UIImpactFeedbackGenerator(style: params.type.toNatively()).impactOccurred()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func vibrateLong(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        bridge.invokeCallbackSuccess(args: args)
    }
}
