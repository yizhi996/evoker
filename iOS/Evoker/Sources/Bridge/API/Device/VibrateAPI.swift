//
//  VibrateAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AudioToolbox

enum VibrateAPI: String, CaseIterableAPI {
    
    case vibrateShort
    case vibrateLong
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .vibrateShort:
                vibrateShort(appService: appService, bridge: bridge, args: args)
            case .vibrateLong:
                vibrateLong(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func vibrateShort(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
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
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: params.type.toNatively())
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func vibrateLong(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        bridge.invokeCallbackSuccess(args: args)
    }
}
