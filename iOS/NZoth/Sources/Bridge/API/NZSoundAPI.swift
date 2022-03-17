//
//  NZSoundAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import AudioToolbox

enum NZSoundAPI: String, NZBuiltInAPI {
    
    case playSystemSound
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
        switch self {
            case .playSystemSound:
                playSystemSound(args: args, bridge: bridge)
            }
        }
    }
    
    private func playSystemSound(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let id = params["id"] as? UInt32 {
            AudioServicesPlaySystemSound(id)
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
